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

-- Crear la función para actualizar patrocinadores y premios
CREATE OR REPLACE FUNCTION actualizar_patrocinadores_premios(patrocinador_id INT, nombre VARCHAR, monto NUMERIC, premio_id INT, descripcion VARCHAR, monto_premio NUMERIC)
RETURNS void AS $$
BEGIN
    -- Actualizar o insertar patrocinadores
    INSERT INTO servicios_movil.Patrocinador (patrocinador_id, nombre, monto)
    VALUES (patrocinador_id, nombre, monto)
    ON CONFLICT (patrocinador_id) DO UPDATE
    SET nombre = EXCLUDED.nombre, monto = EXCLUDED.monto;

    -- Actualizar o insertar premios
    INSERT INTO servicios_movil.Premio (premio_id, descripcion, monto)
    VALUES (premio_id, descripcion, monto_premio)
    ON CONFLICT (premio_id) DO UPDATE
    SET descripcion = EXCLUDED.descripcion, monto = EXCLUDED.monto;
END;
$$ LANGUAGE plpgsql;

-- Configurar job opcional (solo si necesitas ejecutarlo localmente)
SELECT cron.schedule('ActualizarPatrocinadoresPremios', '0 */6 * * *', 'SELECT actualizar_patrocinadores_premios();');
