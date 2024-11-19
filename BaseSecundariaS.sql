-- Consultar los tiempos registrados para un participante específico
SELECT 
    T.participante_id, 
    P.nombre, 
    C.nombre AS carrera, 
    T.tiempo
FROM 
    carreras.Tiempos T
JOIN 
    carreras.Participante P ON T.participante_id = P.participante_id
JOIN 
    carreras.Carrera C ON T.carrera_id = C.carrera_id
WHERE 
    T.participante_id = $1 -- Variable en formato de PostgreSQL
ORDER BY 
    T.tiempo;

-- Consultar todos los detalles de una carrera específica
SELECT 
    C.carrera_id, 
    C.nombre, 
    C.fecha, 
    C.lugar, 
    C.categoria, 
    C.distancia, 
    COUNT(I.inscripcion_id) AS total_participantes
FROM 
    carreras.Carrera C
LEFT JOIN 
    carreras.Inscripcion I ON C.carrera_id = I.carrera_id
WHERE 
    C.carrera_id = $1
GROUP BY 
    C.carrera_id, C.nombre, C.fecha, C.lugar, C.categoria, C.distancia;

-- Listar los participantes inscritos en una carrera específica
SELECT 
    P.participante_id, 
    P.nombre, 
    P.edad, 
    P.genero
FROM 
    carreras.Inscripcion I
JOIN 
    carreras.Participante P ON I.participante_id = P.participante_id
WHERE 
    I.carrera_id = $1
ORDER BY 
    P.nombre;

-- Consultar los premios asociados a una carrera específica
SELECT 
    PR.premio_id, 
    PR.descripcion, 
    PR.monto, 
    PA.nombre AS patrocinador
FROM 
    carreras.Premio PR
JOIN 
    carreras.Patrocinador PA ON PR.carrera_id = PA.carrera_id
WHERE 
    PR.carrera_id = $1;

-- Consultar los patrocinadores de una carrera específica
SELECT 
    PA.patrocinador_id, 
    PA.nombre, 
    PA.monto_aportado
FROM 
    carreras.Patrocinador PA
WHERE 
    PA.carrera_id = $1
ORDER BY 
    PA.nombre;

-- Consultar los tiempos registrados en una carrera específica 
SELECT 
    T.participante_id, 
    P.nombre, 
    T.tiempo
FROM 
    carreras.Tiempos T
JOIN 
    carreras.Participante P ON T.participante_id = P.participante_id
WHERE 
    T.carrera_id = $1
ORDER BY 
    T.tiempo ASC; -- Menor tiempo primero

-- Consultar el resumen de participantes en una carrera específica
SELECT 
    COUNT(I.participante_id) AS total_participantes,
    AVG(P.edad) AS edad_promedio,
    SUM(CASE WHEN P.genero = 'M' THEN 1 ELSE 0 END) AS total_hombres,
    SUM(CASE WHEN P.genero = 'F' THEN 1 ELSE 0 END) AS total_mujeres
FROM 
    carreras.Inscripcion I
JOIN 
    carreras.Participante P ON I.participante_id = P.participante_id
WHERE 
    I.carrera_id = $1;

-- Consulta las carreras disponibles por fecha 
SELECT 
    carrera_id, 
    nombre, 
    fecha, 
    lugar, 
    categoria, 
    distancia
FROM 
    carreras.Carrera
WHERE 
    fecha BETWEEN $1 AND $2
ORDER BY 
    fecha ASC;

-- Consultar los mensajes más recientes de un participante en una carrera
SELECT 
    M.mensaje_id, 
    M.contenido, 
    M.fecha_envio
FROM 
    carreras.Mensaje M
WHERE 
    M.carrera_id = $1
    AND M.participante_id = $2
ORDER BY 
    M.fecha_envio DESC
LIMIT 10; -- Los 10 mensajes más recientes

-- Consulta de premios por carrera
SELECT 
    COUNT(PR.premio_id) AS total_premios,
    SUM(PR.monto) AS monto_total
FROM 
    carreras.Premio PR
WHERE 
    PR.carrera_id = $1;
