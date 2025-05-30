/****** Object:  Table [dbo].[ContosoOrder]    Script Date: 14/04/2025 08:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContosoOrder](
	[ContosoOrderId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerFullName] [nvarchar](100) NULL,
	[totalOrderQuantity] [int] NULL,
	[totalOrderValue] [int] NULL,
	[accountId] [nvarchar](100) NULL,
	[orderId] [nvarchar](100) NULL,
 CONSTRAINT [PK_ContosoOrder] PRIMARY KEY CLUSTERED 
(
	[ContosoOrderId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContosoOrderDetail]    Script Date: 14/04/2025 08:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContosoOrderDetail](
	[ContosoOrderDetailId] [int] IDENTITY(1,1) NOT NULL,
	[quantity] [nvarchar](100) NULL,
	[price] [nvarchar](100) NULL,
	[productID] [nvarchar](100) NULL,
	[orderTotal] [nvarchar](100) NULL,
	[orderId] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[CreateOrder]    Script Date: 14/04/2025 08:40:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateOrder]
    @OrderJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Begin transaction to ensure data consistency
        BEGIN TRANSACTION;
        
        -- Insert into ContosoOrder table
        INSERT INTO ContosoOrder 
            (orderId, AccountId, CustomerFullName, TotalOrderQuantity, TotalOrderValue)
        SELECT 
            JSON_VALUE(@OrderJson, '$.orderId'),
            JSON_VALUE(@OrderJson, '$.accountId'),
            JSON_VALUE(@OrderJson, '$.customerFullName'),
            JSON_VALUE(@OrderJson, '$.totalOrderQuantity'),
            JSON_VALUE(@OrderJson, '$.totalOrderValue')
			
        -- Get the OrderId for use in the detail records
        DECLARE @OrderId NVARCHAR(50) = JSON_VALUE(@OrderJson, '$.orderId');
        
        -- Insert order details from the JSON array
        INSERT INTO ContosoOrderDetail
            (orderId,Quantity, Price, ProductID, OrderTotal)
        SELECT 
            JSON_VALUE(@OrderJson, '$.orderId'),
            JSON_VALUE(OrderDetail.[value], '$.quantity'),
            JSON_VALUE(OrderDetail.[value], '$.price'),
            JSON_VALUE(OrderDetail.[value], '$.productID'),
            JSON_VALUE(OrderDetail.[value], '$.orderTotal')
        FROM OPENJSON(@OrderJson, '$.orderDetails') AS OrderDetail;
        
        COMMIT TRANSACTION;
        
        -- Return success status and the OrderId
        SELECT 'Success' AS Status, @OrderId AS OrderId;
    END TRY
    BEGIN CATCH
        -- Rollback transaction on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Return error information
        SELECT 
            'Error' AS Status,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;
    END CATCH;
END
GO
