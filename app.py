import streamlit as st
from neo4j import GraphDatabase
import pandas as pd
import plotly.express as px

# CONFIGURACIÓN DE NEO4J
URI = "bolt://localhost:7687"
USER = "neo4j"
PASSWORD = "admin123" # Asegúrate de que esta sea tu clave actual

# LÓGICA DE DATOS
def obtener_metricas():
    try:
        driver = GraphDatabase.driver(URI, auth=(USER, PASSWORD))
        query = """
        MATCH (c:Conductor)-[:MANEJA]->(v:Vehiculo)-[:LLEVA]->(p:Pedido)
        RETURN c.nombre AS Conductor, p.peso_toneladas AS Peso, p.prioridad AS Prioridad
        """
        records, _, _ = driver.execute_query(query, database_="neo4j")
        driver.close()
        return [record.data() for record in records]
    except Exception as e:
        return None

# PÁGINA WEB
st.set_page_config(page_title="Logistics Project - UNEG", layout="wide")

st.markdown("""
    <style>
    .main { background-color: #f8f9fa; }
    .stMetric { background-color: #ffffff; padding: 15px; border-radius: 10px; border-left: 5px solid #004a99; box-shadow: 2px 2px 5px rgba(0,0,0,0.05); }
    h1 { color: #003366; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    h3 { color: #004a99; }
    </style>
    """, unsafe_allow_html=True)

# ENCABEZADO
st.title("Sistema de Gestión Logística")
st.markdown("##### **Equipo de Desarrollo:** Roxana Moreno, Alejandro González, Juan García")
st.caption("Universidad Nacional Experimental de Guayana | Ingeniería en Informática")

st.divider()

datos = obtener_metricas()

if datos:
    df = pd.DataFrame(datos)
    
    m1, m2, m3 = st.columns(3)
    with m1:
        st.metric(label="Total de Pedidos", value=len(df))
    with m2:
        st.metric(label="Carga Total Gestionada", value=f"{df['Peso'].sum()} Ton")
    with m3:
        st.metric(label="Estado del Sistema", value="Activo", delta="Sincronizado")

    st.write("") # Espaciado

    # GRÁFICOS 
    col_izq, col_der = st.columns(2)

    with col_izq:
        st.subheader("Análisis de Carga por Operador")
        fig_bar = px.bar(df, x='Conductor', y='Peso', 
                         color='Peso', color_continuous_scale='Blues',
                         labels={'Peso':'Toneladas'},
                         template="plotly_white")
        st.plotly_chart(fig_bar, use_container_width=True)

    with col_der:
        st.subheader("Distribución de Prioridades")
        fig_pie = px.pie(df, names='Prioridad', 
                         color_discrete_sequence=["#003366", '#004a99', "#236baa"],
                         hole=0.4)
        fig_update = fig_pie.update_traces(textposition='inside', textinfo='percent+label')
        st.plotly_chart(fig_pie, use_container_width=True)

    # SECCIÓN DE DATOS
    with st.expander("Ver Registro Detallado de Operaciones"):
        st.dataframe(df.sort_values(by='Peso', ascending=False), use_container_width=True)
        
    if st.button('Sincronizar con Neo4j'):
        st.rerun()

else:
    st.error("Error de enlace: No se pudo establecer conexión con la base de datos Neo4j.")
    st.info("Verifique que la instancia 'LogisticsProject' esté iniciada y las credenciales sean correctas.")