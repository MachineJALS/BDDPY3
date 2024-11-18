-- Selección del esquema
CREATE SCHEMA servicios_movil;

-- Creación de Tablas (Solo las necesarias para servicios móviles)

-- Tabla de Participantes (Replicada)
CREATE TABLE servicios_movil.Participante (
    participante_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    edad INT CHECK (edad > 0),
    genero CHAR(1)
);

-- Tabla de Tiempos (Replicada)
CREATE TABLE servicios_movil.Tiempos (
    tiempo_id SERIAL PRIMARY KEY,
    carrera_id INT NOT NULL,
    participante_id INT NOT NULL REFERENCES servicios_movil.Participante(participante_id),
    tiempo INTERVAL NOT NULL
);

-- Tabla de Mensajes (Replicada)
CREATE TABLE servicios_movil.Mensaje (
    mensaje_id SERIAL PRIMARY KEY,
    carrera_id INT NOT NULL,
    participante_id INT NOT NULL REFERENCES servicios_movil.Participante(participante_id),
    contenido TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para Optimización de Consultas
CREATE INDEX idx_tiempos_participante ON servicios_movil.Tiempos(participante_id);
CREATE INDEX idx_mensaje_fecha_envio ON servicios_movil.Mensaje(fecha_envio);

-- Roles y Permisos

-- Rol para Consultas en la Aplicación Móvil
CREATE ROLE consulta_movil WITH LOGIN PASSWORD 'consulta_movil_password';
GRANT SELECT ON ALL TABLES IN SCHEMA servicios_movil TO consulta_movil;

-- Rol para Mensajes del Chat (Inserción y Consulta)
CREATE ROLE chat_user_movil WITH LOGIN PASSWORD 'chat_user_password';
GRANT SELECT, INSERT ON servicios_movil.Mensaje TO chat_user_movil;

-- Pruebas y Ajustes

-- Tabla de Auditoría Opcional (Para Monitorear Actividades del Servidor Terciario)
CREATE TABLE servicios_movil.Auditoria (
    auditoria_id SERIAL PRIMARY KEY,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
