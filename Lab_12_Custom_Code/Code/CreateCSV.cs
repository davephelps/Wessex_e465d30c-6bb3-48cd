//------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//------------------------------------------------------------

namespace ContosoIntegration
{
    using System;
    using System.Text;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using Microsoft.Azure.Functions.Extensions.Workflows;
    using Microsoft.Azure.Functions.Worker;
    using Microsoft.Extensions.Logging;
    using System.Text.Json;
    using System.Text.Json.Serialization;
    /// <summary>
    /// Represents the CreateCSV flow invoked function.
    /// </summary>
    public class CreateCSV
    {
        private readonly ILogger<CreateCSV> logger;

        public CreateCSV(ILoggerFactory loggerFactory)
        {
            logger = loggerFactory.CreateLogger<CreateCSV>();
        }

        /// <summary>
        /// Executes the logic app workflow.
        /// </summary>
        /// <param name="zipCode">The zip code.</param>
        /// <param name="temperatureScale">The temperature scale (e.g., Celsius or Fahrenheit).</param>
        [Function("CreateCSV")]
        public Task<string> Run([WorkflowActionTrigger] string payload)
        {
            this.logger.LogInformation("Starting CreateCSV");
            var doc = JsonDocument.Parse(payload);
            var root = doc.RootElement;
            var sb = new StringBuilder();
            sb.AppendLine("OrderId,AccountId,CustomerFullName,ProductId,Quantity,Price,OrderTotal,TotalOrderQuantity,TotalOrderValue");
            foreach (var d in root.GetProperty("orderDetails").EnumerateArray())
            {
                sb.AppendLine($"{root.GetProperty("orderId")},{root.GetProperty("accountId")},{root.GetProperty("customerFullName")},"
                    + $"{d.GetProperty("productID")},{d.GetProperty("quantity")},{d.GetProperty("price")},{d.GetProperty("orderTotal")},"
                    + $"{root.GetProperty("totalOrderQuantity")},{root.GetProperty("totalOrderValue")}");
            }
            return Task.FromResult(sb.ToString());
        }

     }
}