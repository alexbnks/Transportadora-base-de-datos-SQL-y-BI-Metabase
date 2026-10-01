# Transportadora-base-de-datos-SQL-y-BI-Metabase 🚐

Un proyecto integral de arquitectura de datos y Business Intelligence para una empresa de transportación turística ubicada en los cabos, México. El proyecto abarca desde el diseño y normalización de la base de datos relacional en **MySQL**, pasando por la simulación de reservas operativas, hasta la visualización ejecutiva en **Metabase** desplegado mediante **Docker**.

---

## 📌 Contexto del Negocio

La empresa opera un servicio de transporte privado de pasajeros cubriendo 5 zonas geográficas (San José del Cabo, Corredor Turístico, Cabo San Lucas, Pacífico y Diamante/Rancho San Lucas) utilizando una flota diversificada de vehículos (Suburban, Hiace, Sprinter, Bus y Escalade).

### Claves
- **Normalización de Tarifas:** Clasificación de precios por zona geográfica y tipo de vehículo.
- **Multimoneda:** Manejo de reservaciones cotizadas en dólares estadounidenses (USD) y cobradas/registradas con tipo de cambio fijo (MXN).
- **Control Operativo:** Monitoreo del rendimiento por chofer, ocupación de la flota y tasa de cancelación de itinerarios.

---

## 🛠️ Tecnologías y Herramientas

- **Base de Datos:** MySQL / MySQL Workbench
- **Visualización & BI:** Metabase (Conectado a MySQL)
- **Infraestructura:** Docker (Contenedor local para Metabase)
- **Lenguaje de Consultas:** SQL (DDL, DML, Agregaciones, JOINs y Window Functions)

---

## 📐 Arquitectura de Datos (Modelo Relacional)

La base de datos relacional `transportadora_db` fue diseñada bajo la **Tercera Forma Normal (3FN)** para garantizar la integridad referencial y evitar redundancias operativas.

### Tablas Principales:
1. `clients`: Información de los clientes (Nombre, correo, teléfono, país de origen).
2. `drivers`: Catálogo de conductores asignados a la flota.
3. `vehicle_types`: Categorías de unidades (Suburban, Hiace, Sprinter, etc.).
4. `vehicles`: Registro físico de unidades y placas asociadas.
5. `zones`: Clasificación de las 5 zonas de la región.
6. `rates`: Matriz tarifaria que vincula zonas y tipos de vehículos.
7. `reservations`: Tabla de hechos relacional que concentra los servicios, itinerario, estatus, tarifa e ingresos.

---

## 📊 Dashboard Metabase

El tablero principal está diseñado para brindar visibilidad y a la toma de decisiones del negocio.

### Principales KPIs e Indicadores Monitoreados:
1. **Métricas Financieras:**
   - Ingresos Totales (USD / MXN)
   - Ticket Promedio por Reservación (USD)
   - Volumen de Reservaciones Completadas vs. Canceladas

2. **Rendimiento Operativo:**
   - Servicios y Facturación por Chofer
   - Distribución de Demanda por Hoteles/Destinos Frecuentes
   
   <img width="1046" height="550" alt="Captura de pantalla 2026-09-30 a la(s) 6 45 13 p m" src="https://github.com/user-attachments/assets/21f8a1bb-bd5d-4c36-a403-01e45d018193" />


---

## 🔍 Consultas SQL Analíticas Destacadas

### 1. Rendimiento y Facturación por Chofer
```sql
SELECT 
    d.full_name AS chofer,
    vt.type_name AS tipo_vehiculo,
    COUNT(r.reservation_id) AS total_servicios,
    SUM(r.total_usd) AS ingresos_generados_usd
FROM reservations r
JOIN drivers d ON r.driver_id = d.driver_id
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN vehicle_types vt ON v.type_id = vt.type_id
WHERE r.status = 'completed'
GROUP BY d.driver_id, d.full_name, vt.type_name
ORDER BY total_servicios DESC;
```

## Replicar el Proyecto Localmente

Para ejecutar este proyecto en tu entorno local para explorar la base de datos:

### 1. Requisitos Previos
*  MySQL Workbench.
* Docker Desktop (opcional).

### 2. Configuración de la Base de Datos
1. Ejecutar:
   ```bash
  git clone [https://github.com/tu-usuario/nombre-del-repositorio.git](https://github.com/tu-usuario/nombre-del-repositorio.git)


  2. Ejecuta los scripts SQL  en el siguiente orden:
   - `01_esquema.sql` (crea la base de datos `transportadora_db` y sus tablas).
   - `02_datos.sql` (inserta los catálogos y datos de prueba).
   - `03_consultas_bi.sql` (consultas analíticas para explorar las métricas).

---

## Estructura del Repositorio

```text
├── 01_esquema.sql         # Definición de esquema y tablas 
├── 02_datos.sql           # Inserción de catálogos y registros 
├── 03_consultas_bi.sql    # Consultas analíticas para dashboards
└── README.md              # Documentación principal del proyecto
