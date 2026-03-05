// SCRIPT DE CONFIGURACIÓN: PROYECTO LOGÍSTICA UNEG
// Autores: Roxana Moreno, Alejandro González, Juan García

// 1. LIMPIEZA DE BASE DE DATOS 
MATCH (n) DETACH DELETE n;

// 2. CREACIÓN DE NODOS (Almacenes e Intersecciones)
CREATE (a1:Almacen {id: 'A1', nombre: 'Galpón Principal Unare', capacidad_m3: 5000})
CREATE (p1:PuntoEntrega {id: 'P1', nombre: 'Cliente Alta Vista'})
CREATE (p2:PuntoEntrega {id: 'P2', nombre: 'Cliente San Félix'})
CREATE (p3:PuntoEntrega {id: 'P3', nombre: 'Distribuidora Puerto Ordaz'})
CREATE (i1:Interseccion {id: 'I1', nombre: 'Redoma de la Piña'})
CREATE (i2:Interseccion {id: 'I2', nombre: 'Cruce Makro'});

// 3. CREACIÓN DE PERSONAL 
CREATE (c1:Conductor {id: 'C1', nombre: 'Roxana Moreno'})
CREATE (c2:Conductor {id: 'C2', nombre: 'Alejandro González'})
CREATE (c3:Conductor {id: 'C3', nombre: 'Juan García'})

CREATE (v1:Vehiculo {id: 'V1', placa: 'GUA-123', tipo: 'Camión Carga Pesada', capacidad_toneladas: 20})
CREATE (v2:Vehiculo {id: 'V2', placa: 'BOL-456', tipo: 'Furgón Mediano', capacidad_toneladas: 10})
CREATE (v3:Vehiculo {id: 'V3', placa: 'UNE-789', tipo: 'Camioneta Reparto', capacidad_toneladas: 5});

// 4. CREACIÓN DE PEDIDOS (Con pesos y prioridades para el Dashboard)
CREATE (ped1:Pedido {id: 'PED-001', descripcion: 'Suministros Industriales', peso_toneladas: 12, prioridad: 'Alta'})
CREATE (ped2:Pedido {id: 'PED-002', descripcion: 'Equipos de Oficina', peso_toneladas: 4, prioridad: 'Media'})
CREATE (ped3:Pedido {id: 'PED-003', descripcion: 'Material de Construcción', peso_toneladas: 3, prioridad: 'Urgente'});

// 5. ESTABLECIMIENTO DE RELACIONES OPERATIVAS
// Asignación de vehículos a conductores y ubicación en almacén
MATCH (c1:Conductor {nombre: 'Roxana Moreno'}), (v3:Vehiculo {placa: 'UNE-789'}), (a1:Almacen {id: 'A1'})
CREATE (c1)-[:MANEJA]->(v3), (v3)-[:UBICADO_EN]->(a1);

MATCH (c2:Conductor {nombre: 'Alejandro González'}), (v1:Vehiculo {placa: 'GUA-123'}), (a1:Almacen {id: 'A1'})
CREATE (c2)-[:MANEJA]->(v1), (v1)-[:UBICADO_EN]->(a1);

MATCH (c3:Conductor {nombre: 'Juan García'}), (v2:Vehiculo {placa: 'BOL-456'}), (a1:Almacen {id: 'A1'})
CREATE (c3)-[:MANEJA]->(v2), (v2)-[:UBICADO_EN]->(a1);

// Asignación de pedidos a vehículos y destinos
MATCH (v1:Vehiculo {placa: 'GUA-123'}), (ped1:Pedido {id: 'PED-001'}), (p1:PuntoEntrega {id: 'P1'})
CREATE (v1)-[:LLEVA]->(ped1), (ped1)-[:ENTREGAR_EN]->(p1);

MATCH (v2:Vehiculo {placa: 'BOL-456'}), (ped2:Pedido {id: 'PED-002'}), (p2:PuntoEntrega {id: 'P2'})
CREATE (v2)-[:LLEVA]->(ped2), (ped2)-[:ENTREGAR_EN]->(p2);

MATCH (v3:Vehiculo {placa: 'UNE-789'}), (ped3:Pedido {id: 'PED-003'}), (p3:PuntoEntrega {id: 'P3'})
CREATE (v3)-[:LLEVA]->(ped3), (ped3)-[:ENTREGAR_EN]->(p3);

// 6. RED VIAL (Para algoritmo de Dijkstra)
MATCH (a1:Almacen {id: 'A1'}), (i1:Interseccion {id: 'I1'})
CREATE (a1)-[:CONECTA_A {distancia_km: 5, costo_trafico: 10, capacidad_maxima: 30}]->(i1);

MATCH (i1:Interseccion {id: 'I1'}), (p1:PuntoEntrega {id: 'P1'})
CREATE (i1)-[:CONECTA_A {distancia_km: 8, costo_trafico: 15, capacidad_maxima: 20}]->(p1);

MATCH (i1:Interseccion {id: 'I1'}), (p2:PuntoEntrega {id: 'P2'})
CREATE (i1)-[:CONECTA_A {distancia_km: 12, costo_trafico: 25, capacidad_maxima: 25}]->(p2);

// 7. PROYECCIÓN DEL GRAFO
CALL gds.graph.project(
  'grafo_logistica',
  ['Almacen', 'PuntoEntrega', 'Interseccion'],
  'CONECTA_A',
  { relationshipProperties: ['distancia_km', 'costo_trafico', 'capacidad_maxima'] }
);