-- Crear esquema para la base de datos
CREATE SCHEMA carreras;

-- Tabla de Carreras
CREATE TABLE carreras.Carrera (
    carrera_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha DATE NOT NULL,
    lugar VARCHAR(100),
    categoria VARCHAR(50),
    distancia INT NOT NULL
);

-- Tabla de Participantes
CREATE TABLE carreras.Participante (
    participante_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    edad INT CHECK (edad > 0),
    genero CHAR(1)
);

-- Tabla de Inscripciones
CREATE TABLE carreras.Inscripcion (
    inscripcion_id SERIAL PRIMARY KEY,
    carrera_id INT NOT NULL REFERENCES carreras.Carrera(carrera_id),
    participante_id INT NOT NULL REFERENCES carreras.Participante(participante_id),
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    estado_pago BOOLEAN DEFAULT FALSE
);

-- Tabla de Tiempos
CREATE TABLE carreras.Tiempos (
    tiempo_id SERIAL PRIMARY KEY,
    carrera_id INT NOT NULL REFERENCES carreras.Carrera(carrera_id),
    participante_id INT NOT NULL REFERENCES carreras.Participante(participante_id),
    tiempo INTERVAL NOT NULL
);

-- Tabla de Patrocinadores
CREATE TABLE carreras.Patrocinador (
    patrocinador_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    monto_aportado NUMERIC CHECK (monto_aportado > 0),
    carrera_id INT REFERENCES carreras.Carrera(carrera_id)
);

-- Tabla de Premios
CREATE TABLE carreras.Premio (
    premio_id SERIAL PRIMARY KEY,
    carrera_id INT NOT NULL REFERENCES carreras.Carrera(carrera_id),
    descripcion VARCHAR(255),
    monto NUMERIC CHECK (monto > 0)
);

-- Tabla de Mensajes
CREATE TABLE carreras.Mensaje (
    mensaje_id SERIAL PRIMARY KEY,
    carrera_id INT NOT NULL REFERENCES carreras.Carrera(carrera_id),
    participante_id INT NOT NULL REFERENCES carreras.Participante(participante_id),
    contenido TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE carreras.EstadisticasCarreras (
    estadistica_id SERIAL PRIMARY KEY,
    carrera_id INT NOT NULL,
    total_participantes INT,
    tiempo_promedio INTERVAL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Crear índices para optimización de consultas frecuentes
CREATE INDEX idx_carrera_fecha ON carreras.Carrera(fecha);
CREATE INDEX idx_participante_nombre ON carreras.Participante(nombre);
CREATE INDEX idx_tiempos_participante_carrera ON carreras.Tiempos(participante_id, carrera_id);
CREATE INDEX idx_mensaje_fecha ON carreras.Mensaje(fecha_envio);

-- Roles y Permisos

-- Rol para Administrador (Acceso total)
CREATE ROLE admin WITH LOGIN PASSWORD 'admin_password';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA carreras TO admin;

-- Rol para Lectura General (Consultas sin modificación)
CREATE ROLE consulta WITH LOGIN PASSWORD 'consulta_password';
GRANT SELECT ON ALL TABLES IN SCHEMA carreras TO consulta;

-- Rol para Replicación (Sin acceso directo, solo para uso interno)
CREATE ROLE replicacion WITH LOGIN PASSWORD 'replicacion_password';
GRANT USAGE ON SCHEMA carreras TO replicacion;

-- Rol para Chat (Lectura y escritura en Mensaje)
CREATE ROLE chat_user WITH LOGIN PASSWORD 'chat_password';
GRANT SELECT, INSERT ON carreras.Mensaje TO chat_user;

-- Jobs

-- Crear Job para limpiar mensajes antiguos
CREATE OR REPLACE FUNCTION limpiar_mensajes_chat()
RETURNS void AS $$
BEGIN
    DELETE FROM carreras.Mensaje
    WHERE fecha_envio < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- Agregar la tarea programada (ejecutar diariamente a medianoche)
SELECT cron.schedule('LimpiezaMensajesChat', '0 0 * * *', 'SELECT limpiar_mensajes_chat();');
