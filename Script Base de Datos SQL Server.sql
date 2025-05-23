Create database [Products]
go
USE [Products]
GO
/****** Object:  Table [dbo].[Productos]    Script Date: 13/04/2025 6:38:36 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Productos](
	[id] [int] NULL,
	[title] [varchar](100) NULL,
	[price] [decimal](10, 2) NULL,
	[category] [varchar](100) NULL,
	[description] [varchar](100) NULL,
	[fecha_insercion] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Productos] ADD  DEFAULT (getdate()) FOR [fecha_insercion]
GO
/****** Object:  StoredProcedure [dbo].[InsertarProducto]    Script Date: 13/04/2025 6:38:37 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertarProducto]
    @id INT,
    @title VARCHAR(100),
    @price DECIMAL(10, 2),
    @category VARCHAR(100),
    @description VARCHAR(100)
AS
BEGIN
    BEGIN TRY
        -- Verificar si el ID ya existe
        IF EXISTS (SELECT 1 FROM Productos WHERE id = @id)
        BEGIN
            SELECT 'Registro Existe: No fue ingresado' AS Mensaje;
        END
        ELSE
        BEGIN
            -- Insertar el producto
            INSERT INTO Productos (id, title, price, category, description)
            VALUES (@id, @title, @price, @category, @description);

            SELECT 'Registro Insertado' AS Mensaje;
        END
    END TRY
    BEGIN CATCH
        -- Retornar el mensaje de error si ocurre alguna excepción
        SELECT 
            'Error: ' + ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[ListarProductos]    Script Date: 13/04/2025 6:38:37 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ListarProductos]
    @ordenCampo VARCHAR(50),
    @ordenDireccion VARCHAR(4)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    -- Validación simple para evitar inyecciones o campos inválidos
    IF @ordenCampo NOT IN ('id', 'title', 'price', 'category', 'description')
        SET @ordenCampo = 'fecha_insercion';  -- campo por defecto

    IF @ordenDireccion NOT IN ('ASC', 'DESC')
        SET @ordenDireccion = 'ASC';  -- dirección por defecto

    -- Construcción dinámica del SQL con orden
    SET @sql = N'
        SELECT id as ID, title AS TITULO, price AS PRECIO, category AS CATEGORIA, description AS DESCRIPCION, fecha_insercion AS FECHA_INSERT
        FROM Productos 
        ORDER BY ' + QUOTENAME(@ordenCampo) + ' ' + @ordenDireccion;

    EXEC sp_executesql @sql;
END;
GO
/****** Object:  StoredProcedure [dbo].[ResumenProductos]    Script Date: 13/04/2025 6:38:37 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ResumenProductos]
AS
BEGIN
    -- Cantidad total de productos
    SELECT 'Cantidad total de productos' AS Descripcion, CAST(COUNT(*) AS VARCHAR) AS Valor
    FROM Productos

    UNION ALL

    -- Precio promedio general (formateado a 2 decimales)
    SELECT 'Precio promedio general', FORMAT(AVG(price), 'N2')
    FROM Productos

    UNION ALL

    -- Precio promedio por categoría (formateado a 2 decimales)
    SELECT 'Precio promedio en categoría: ' + category, FORMAT(AVG(price), 'N2')
    FROM Productos
    GROUP BY category

    UNION ALL

    -- Cantidad de productos por categoría
    SELECT 'Cantidad de productos en categoría: ' + category, CAST(COUNT(*) AS VARCHAR)
    FROM Productos
    GROUP BY category
END;
GO
