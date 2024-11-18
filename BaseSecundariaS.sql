-- Seleccionar base de datos (asegúrate de estar en la correcta)
USE CarrerasDB; 
GO

-- Creación de Tablas (Estructura Replicada)
-- Estas tablas ya deberían existir debido a la replicación, pero agregamos índices locales y roles específicos.

-- Índices Locales para Optimización de Consultas
CREATE INDEX idx_carrera_fecha ON Carrera(fecha);
CREATE INDEX idx_participante_nombre ON Participante(nombre);
CREATE INDEX idx_tiempos_participante_carrera ON Tiempos(participante_id, carrera_id);
CREATE INDEX idx_mensaje_fecha ON Mensaje(fecha_envio);

-- Creación de Roles y Permisos

-- Rol para Administradores Secundarios (Consulta y mantenimiento básico)
CREATE LOGIN admin_secundario WITH PASSWORD = 'admin_secundario_password';
CREATE USER admin_secundario FOR LOGIN admin_secundario;
GRANT SELECT, INSERT, UPDATE, DELETE ON Carrera TO admin_secundario;
GRANT SELECT, INSERT, UPDATE, DELETE ON Participante TO admin_secundario;
GRANT SELECT, INSERT, UPDATE, DELETE ON Inscripcion TO admin_secundario;
GRANT SELECT, INSERT, UPDATE, DELETE ON Tiempos TO admin_secundario;
GRANT SELECT, INSERT, UPDATE, DELETE ON Patrocinador TO admin_secundario;
GRANT SELECT, INSERT, UPDATE, DELETE ON Premio TO admin_secundario;
GRANT SELECT, INSERT, UPDATE, DELETE ON Mensaje TO admin_secundario;

-- Rol para Usuarios de Solo Consulta
CREATE LOGIN consulta_secundario WITH PASSWORD = 'consulta_secundario_password';
CREATE USER consulta_secundario FOR LOGIN consulta_secundario;
GRANT SELECT ON Carrera TO consulta_secundario;
GRANT SELECT ON Participante TO consulta_secundario;
GRANT SELECT ON Inscripcion TO consulta_secundario;
GRANT SELECT ON Tiempos TO consulta_secundario;
GRANT SELECT ON Patrocinador TO consulta_secundario;
GRANT SELECT ON Premio TO consulta_secundario;
GRANT SELECT ON Mensaje TO consulta_secundario;

-- Rol para Mantenimiento de Estadísticas
CREATE LOGIN estadisticas_secundario WITH PASSWORD = 'estadisticas_password';
CREATE USER estadisticas_secundario FOR LOGIN estadisticas_secundario;
GRANT SELECT, INSERT, UPDATE ON EstadisticasCarreras TO estadisticas_secundario;

-- Creación de Tabla de Estadísticas (Solo en Secundarios)
CREATE TABLE EstadisticasCarreras (
    estadistica_id INT IDENTITY(1,1) PRIMARY KEY,
    carrera_id INT NOT NULL REFERENCES Carrera(carrera_id),
    total_participantes INT NOT NULL,
    tiempo_promedio NUMERIC(10, 2) NOT NULL,
    fecha_calculo DATETIME DEFAULT GETDATE()
);
