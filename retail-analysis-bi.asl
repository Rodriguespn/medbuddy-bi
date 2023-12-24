Package retail_analysis

Import bi.bi_types


System retail_analysis_bi: Application 

DataEnumeration enum_StoreTypes values (NewStore, SameStore)

DataEntity Districts "Districts Dimension" : Master : BI_Dimension [
  attribute DistrictID "DistrictID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute BusinessUnitID "BusinessUnitID" : Integer [constraints (NotNull)]
  attribute District "District" : String(50) [constraints (NotNull)]
  attribute DM "DM" : String(50) [constraints (NotNull)]
  attribute DMPic "DM Pic" : String(100) [constraints (NotNull)]
  attribute DMPicfl "DM Pic fl" : String(100) [constraints (NotNull)]
  attribute DMImage "DMImage" : String(100) [constraints (NotNull)]
  description "This dimension represents the various districts and associated attributes."
]

DataEntity Items "Items Dimension" : Master : BI_Dimension [
  attribute ItemID "ItemID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute Segment "Segment" : String(50) [constraints (NotNull)]
  attribute Category "Category" : String(50) [constraints (NotNull)]
  attribute Buyer "Buyer" : String(50) [constraints (NotNull)]
  attribute FamilyName "FamilyName" : String(50) [constraints (NotNull)]
  description "This dimension represents different types of items and their attributes."
]

DataEntity _Time "Time Dimension" : Reference : BI_Dimension [
  attribute ReportingPeriodID "ReportingPeriodID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute Period "Period" : String(20) [constraints (NotNull)]
  attribute FiscalYear "FiscalYear" : Integer [constraints (NotNull)]
  attribute FiscalMonth "FiscalMonth" : String(20) [constraints (NotNull)]
  attribute Month "Month" : String(20) [constraints (NotNull)]
  description "This dimension provides different time attributes for reporting."
]

DataEntity Stores "Stores Fact": Transaction : BI_Fact [
  attribute LocationID "Location ID" : Integer [constraints (PrimaryKey NotNull Unique)]
  attribute CityName "City Name" : String(50) [constraints (NotNull)]
  attribute Territory "Territory" : String(50) [constraints (NotNull)]
  attribute PostalCode "Postal Code" : String(10) [constraints (NotNull)]
  attribute OpenDate "Open Date" : Date [constraints (NotNull)]
  attribute SellingAreaSize "Selling Area Size" : Decimal [constraints (NotNull)]
  attribute DistrictID "District ID" : Integer [constraints (NotNull ForeignKey(Districts))]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute StoreNumber "Store Number" : Integer [constraints (NotNull)]
  attribute Chain "Chain" : String(50) [constraints (NotNull)]
  attribute DM "DM" : String(50) [constraints (NotNull)]
  attribute DMPic "DM Pic" : String(100) [constraints (NotNull)]
  attribute OpenYear "Open Year" : Integer [constraints (NotNull)]
  attribute StoreType "Store Type" : DataEnumeration enum_StoreTypes [constraints (NotNull)]
  attribute OpenMonthNo "Open Month No" : Integer [constraints (NotNull)]
  attribute OpenMonth "Open Month" : String(20) [constraints (NotNull)]
  attribute AverageSellingAreaSize "Average Selling Area Size" : Decimal [formula details: sum(SellingAreaSize) tag (name "expression" value "average(SellingAreaSize)")]
  attribute NewStores "New Stores" : Integer [formula details: count(Stores) tag (name "expression" value "count(if(StoreType = enum_StoreTypes.NewStore))")]
  attribute NewStoresTarget "New Stores Target" : String(5) [defaultValue "14"]
  attribute OpenStoreCount "Open Store Count" : Integer [formula details: count(Stores) tag (name "expression" value "count(Stores.OpenDate)")]
  attribute TotalStores "Total Stores" : Integer [formula details: count(Stores)]
  description "This fact table represents various attributes and measures related to stores."
]

DataEntity Sales "Sales Fact" : Transaction : BI_Fact [
  attribute ItemID "Item ID" : Integer [constraints (NotNull ForeignKey(Items))]
  attribute LocationID "Location ID" : Integer [constraints (NotNull ForeignKey(Stores))]
  attribute ReportingPeriodID "Reporting Period ID" : Integer [constraints (NotNull ForeignKey(_Time))]
  attribute MonthID "Month ID" : Integer [constraints (NotNull)]
  attribute ScenarioID "Scenario ID" : Integer [constraints (NotNull)]
  attribute SumGrossMarginAmount "Sum Gross Margin Amount" : Decimal [constraints (NotNull)]
  attribute SumMarkdownSalesDollars "Sum Markdown Sales Dollars" : Decimal [constraints (NotNull)]
  attribute SumMarkdownSalesUnits "Sum Markdown Sales Units" : Decimal [constraints (NotNull)]
  attribute SumRegularSalesDollars "Sum Regular Sales Dollars" : Decimal [constraints (NotNull)]
  attribute SumRegularSalesUnits "Sum Regular Sales Units" : Decimal [constraints (NotNull)]
  attribute LastYearSales "Last Year Sales" : Decimal [constraints (NotNull)]
  attribute MarkdownSalesDollars "Markdown Sales Dollars" : Decimal [formula details: sum(SumMarkdownSalesDollars)]
  attribute MarkdownSalesUnits "Markdown Sales Units" : Decimal [formula details: sum(SumMarkdownSalesUnits)]
  attribute RegularSalesDollars "Regular Sales Dollars" : Decimal [formula details: sum(SumRegularSalesDollars)]
  attribute RegularSalesUnits "Regular Sales Units" : Decimal [formula details: sum(SumRegularSalesUnits)]
  attribute SalesPerSqFt "Sales Per Square Feet" : Decimal [formula details: sum(TotalSales) tag (name "expression" value "TotalSales / (count(Stores) * sum(SellingAreaSize))")]
  attribute StoreCount "Store Count" : Integer [formula details: count(Stores)]
  attribute TotalUnitsLastYear "Total Units Last Year" : Decimal [constraints (NotNull)]
  attribute TotalUnitsThisYear "Total Units This Year" : Decimal [constraints (NotNull)]
  attribute TotalSales "Total Sales" : Decimal [formula arithmetic (RegularSalesDollars + Sales.MarkdownSalesDollars)]
  attribute TotalSalesLY "Total Sales Last Year" : Decimal [constraints (NotNull)]
  attribute TotalSalesTY "Total Sales This Year" : Decimal [constraints (NotNull)]
  attribute TotalSalesVar "Total Sales Variance" : Decimal [formula arithmetic (TotalSalesTY - TotalSalesLY)]
  attribute TotalSalesVarPercentage "Total Sales Variance %" : Decimal [formula arithmetic ((TotalSalesVar / TotalSalesLY) * 100) constraints (NotNull)]
  attribute AverageUnitPrice "Average Unit Price" : Decimal [formula arithmetic (SumRegularSalesDollars / SumRegularSalesUnits) constraints (NotNull) tag (name "expression" value "average(SumRegularSalesDollars / SumRegularSalesUnits)")]
  attribute AverageUnitPriceLastYear "Average Unit Price Last Year" : Decimal [formula arithmetic (LastYearSales / TotalUnitsLastYear) constraints (NotNull) tag (name "expression" value "average(LastYearSales / TotalUnitsLastYear)")]
  attribute AvgDollarPerUnitLastYear "Avg $/Unit LY" : Decimal [formula arithmetic (TotalSalesLY / TotalUnitsLastYear) constraints (NotNull)]
  attribute AvgDollarPerUnitThisYear "Avg $/Unit TY" : Decimal [formula arithmetic (TotalSalesTY / TotalUnitsThisYear) constraints (NotNull)]
  attribute GrossMarginLastYear "Gross Margin Last Year" : Decimal [formula arithmetic (LastYearSales - SumGrossMarginAmount) constraints (NotNull) tag (name "expression" value "sum(LastYearSales - SumGrossMarginAmount)")]
  attribute GrossMarginLastYearPercentage "Gross Margin Last Year %" : Decimal [formula arithmetic ((GrossMarginLastYear / TotalSalesLY) * 100) constraints (NotNull)]
  attribute GrossMarginThisYear "Gross Margin This Year" : Decimal [formula arithmetic (TotalSalesTY - SumGrossMarginAmount) constraints (NotNull) tag (name "expression" value "sum(TotalSalesTY - SumGrossMarginAmount)")]
  attribute GrossMarginThisYearPercentage "Gross Margin This Year %" : Decimal [formula arithmetic ((GrossMarginThisYear / TotalSalesTY) * 100) constraints (NotNull)]
  description "This fact table represents various sales metrics, providing insights into sales performance, margins, and trends."
]

DataEntityCluster dec_Stores : Transaction [
    main Stores
    uses Districts    
]

DataEntityCluster dec_Sales : Transaction [
    main Sales
    uses Stores, Districts, _Time, Items
]

Actor a_Company_Data_Analyst : User [description "The company's data analyst"]
Actor a_DM "Distric Manager" : User [description "The company's district manager"]
Actor a_CFO "Chief Financial Officer" : User [description "The company'’'s Chief Financial Officer"]

UseCase uc_Analysis_Sales_National_Level_By_CFO : BIInteraction: DataAnalysis [
  actorInitiates a_CFO
  dataEntity dec_Sales

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown
  tag (name "BI-Action:BI_Slice:NationalSalesOverview" value "Dimensions:'_Time, Districts'")
  tag (name "BI-Action:BI_Dice:SalesByItemCategoryAndTime" value "Dimensions:'_Time, Items'")
  tag (name "BI-Action:BI_RollUp:SalesByDistrict" value "Dimensions:'Districts'")
  tag (name "BI-Action:BI_DrillDown:SalesDetailsByStore" value "Dimensions:'Stores'")

  description "Provides a comprehensive overview of sales and store data at a national level for the CFO"
]

UseCase uc_Analysis_Sales_District_Level_By_DM : BIInteraction: DataAnalysis [
  actorInitiates a_DM
  dataEntity dec_Sales

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown

  tag (name "BI-Action:BI_Slice:DistrictSalesOverview" value "Dimensions:'_Time, Districts'")
  tag (name "BI-Action:BI_Dice:SalesByItemInDistrict" value "Dimensions:'Districts, Items'")
  tag (name "BI-Action:BI_RollUp:SalesSummaryByTimeInDistrict" value "Dimensions:'_Time, Districts'")
  tag (name "BI-Action:BI_DrillDown:DetailedSalesByStoreInDistrict" value "Dimensions:'Stores, Districts'")

  description "Enables the District Manager to analyse sales and store data at a district level"
]

UseCase uc_Import_Last_Year_Financial_Data : BIInteraction : DataImport [
  actorInitiates a_CFO
  dataEntity dec_Sales

  actions BI_Import  
]

UseCase uc_ FilterSalesByDistrictManager : BIInteraction : DataQuerying [
  actorInitiates a_Data_Analyst
  dataEntity dec_Sales

  actions BI_Slice

  tag (name "BI-Action:BI_Slice: ScheduledAppointmentsInSpecificYear " value "Dimensions:'e_Districts'") 
]

component fi_District_Manager_Filter "District Manager Filter" : Filter : Dropdown [
  dataBinding Districts
  
  part DM "District Manager" : Field : Option [dataAttributeBinding Districts.DM]

  event e_ApplyFilter : Submit : Submit_Update [navigationFlowTo fi_District_Manager_Filter tag (name "DM Slice" value "Slice Districts by their district manager")]
  event e_ResetFilter : Submit : Submit_Update [navigationFlowTo fi_District_Manager_Filter tag (name "Reset" value "Clear the district manager filter")]
]

component fi_New_Stores_Name_Filter "New Stores Name Filter" : Filter : Dropdown [
  dataBinding dec_Stores
  
  part StoreName "Store Name" : Field : Option [dataAttributeBinding Stores.Name]

  event e_ApplyFilter : Submit : Submit_Update [navigationFlowTo fi_New_Stores_Name_Filter tag (name "Stores Slice" value "Slice Stores by their name")]
  event e_ResetFilter : Submit : Submit_Update [navigationFlowTo fi_New_Stores_Name_Filter tag (name "Reset" value "Clear the new stores filter")]
]

D.2. Cards:

component uiCo_New_Stores_Card "New Stores Card" : Card [
  dataBinding dec_Stores
    
  part NewStores "New Stores" : Field : Value [dataAttributeBinding Stores.NewStores]

  event RefreshData : Submit : Submit_Update [tag (name "Refresh" value "Refresh the new stores count")]
]

component uiCo_Total_Stores_Card "Total Stores Card" : Card [
  dataBinding dec_Stores
    
  part TotalStores "Total Stores" : Field : Value [dataAttributeBinding Stores.TotalStores]

  event RefreshData : Submit : Submit_Update [tag (name "Refresh" value "Refresh the total stores count")]
]

component uiCo_This_Year_Sales_by_Chain_PieChart "This Year Sales by Chain" : InteractiveChart : InteractivePieChart [
  dataBinding dec_Sales
  // The chart segments
  part Chain "Chain" : Field : Label [dataAttributeBinding Stores.Chain]
  part TotalSalesTY "Total Sales This Year" : Field : Value [dataAttributeBinding Sales.TotalSalesTY]

  event TooltipAndHoverDetails : Other
]

component uiCo_Total_Sales_Variance_by_FiscalMonth_and_District_Manager_BarChart : InteractiveChart : InteractiveBarChart [
  dataBinding dec_Sales  
  // The chart axes
  part FiscalMonth "Fiscal Month" : Field : X_Axis [dataAttributeBinding Time.FiscalMonth]
  part TotalSalesVariance "Total Sales Variance" : Field : Y_Axis [dataAttributeBinding Sales.TotalSalesVar]
  part DM "District Manager" : Field : Legend [dataAttributeBinding Districts.DM]

  event TooltipAndHoverDetails : Other
  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_Total_Sales_Variance_by_FiscalMonth_and_District_Manager_BarChart]
]

component uiCo_This_Year_Sales_by_PostalCode_and_Store_Type_Map : InteractiveChart : InteractiveGeographicalMap [
  dataBinding dec_Sales  
  // The map elements
  part PostalCode "Postal Code" : Field : Latitude [dataAttributeBinding Stores.PostalCode]
  part TotalSalesTY "Total Sales This Year" : Field : Longitude [dataAttributeBinding Sales.TotalSalesTY]
  part StoreType "Store Type" : Field : Legend [dataAttributeBinding Stores.StoreType]

  event ZoomAndPanUpdate : Submit : Submit_Update [navigationFlowTo uiCo_This_Year_Sales_by_PostalCode_and_Store_Type_Map]
  event RealTimeDataUpdate : Submit : Submit_Update [navigationFlowTo uiCo_This_Year_Sales_by_PostalCode_and_Store_Type_Map]
  event TooltipAndHoverDetails : Other
]

component uiCo_Total_Sales_Variance_Percentage_Sales_Per_Sq_Ft_and_This_Year_Sales_by_District_and_District_ScatterPlot : InteractiveChart : InteractiveScatterPlot [
  dataBinding dec_Sales
  // The chart axes
  part SalesPerSqFt "Sales Per Sq Ft" : Field : X_Axis [dataAttributeBinding Sales.SalesPerSqFt]
  part TotalSalesVariancePercentage "Total Sales Variance %" : Field : Y_Axis [dataAttributeBinding Sales.TotalSalesVarPercentage]
  part District "District" : Field : Label [dataAttributeBinding Districts.District]

  event TooltipAndHoverDetails : Other
  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_Total_Sales_Variance_Percentage_Sales_Per_Sq_Ft_and_This_Year_Sales_by_District_and_District_ScatterPlot]
]

component uiCo_Total_Sales_Variance_Percentage_by_FiscalMonth_BarChart : InteractiveChart : InteractiveBarChart [
  dataBinding dec_Sales
  // Chart axes
  part FiscalMonth "Fiscal Month" : Field : X_Axis [dataAttributeBinding _Time.FiscalMonth]
  part TotalSalesVariancePercentage "Total Sales Variance %" : Field : Y_Axis [dataAttributeBinding Sales.TotalSalesVarPercentage]

  event TooltipAndHoverDetails : Other
  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_Total_Sales_Variance_Percentage_by_FiscalMonth_BarChart]
]

component uiCo_This_Year_Sales_by_StoreNumberName_BarChart : InteractiveChart : InteractiveBarChart [
  dataBinding dec_Sales
  // Chart axes
  part StoreNumberName "Store Number Name" : Field : X_Axis [dataAttributeBinding Stores.Name]
  part TotalSalesTY "Total Sales This Year" : Field : Y_Axis [dataAttributeBinding Sales.TotalSalesTY]

  event TooltipAndHoverDetails : Other
  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_This_Year_Sales_by_StoreNumberName_BarChart]
]

component uiCo_LastYearSalesandThisYearSalesbyQuarter : InteractiveChart : InteractiveAreaChart [
  dataBinding dec_Sales
  // Chart axes
  part sales_date : Field : X_Axis [dataAttributeBinding e_Sales.ReportingPeriodID]
  part lastYearSales : Field : Y_Axis [dataAttributeBinding e_Sales. Sales.LastYearSales]
  part thisYearSales : Field : Y_Axis [dataAttributeBinding e_Sales. Sales.ThisYearSales]

  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_LastYearSalesandThisYearSalesbyQuarter]
  event TooltipAndHoverDetails : Other ]

component uiCo_Total_Sales_Variance_Percentage_Avg_Unit_TY_and_This_Year_Sales_by_Category_and_Category_ScatterPlot : InteractiveChart : InteractiveScatterPlot [
  dataBinding dec_Sales  
  // Chart axes
  part AverageUnitPrice "Average Unit Price" : Field : X_Axis [dataAttributeBinding Sales.AverageUnitPrice]
  part TotalSalesVariancePercentage "Total Sales Variance %" : Field : Y_Axis [dataAttributeBinding Sales.TotalSalesVarPercentage]
  part Category "Category" : Field : Label [dataAttributeBinding Items.Category]

  event TooltipAndHoverDetails : Other
  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_Total_Sales_Variance_Percentage_Avg_Unit_TY_and_This_Year_Sales_by_Category_and_Category_ScatterPlot]
]

component uiCo_This_Year_Sales_by_City_and_Chain_Map : InteractiveChart : InteractiveGeographicalMap [
  dataBinding dec_Sales
  // Chart layers
  part City "City" : Field : Location [dataAttributeBinding Stores.CityName]
  part Chain "Chain" : Field : Legend [dataAttributeBinding Stores.Chain]
  part ThisYearSales "This Year Sales" : Field : Value [dataAttributeBinding Sales.TotalSalesTY]

  event ZoomAndPanUpdate : Submit : Submit_Update [navigationFlowTo uiCo_This_Year_Sales_by_City_and_Chain_Map]
  event RealTimeDataUpdate : Submit : Submit_Update [navigationFlowTo uiCo_This_Year_Sales_by_City_and_Chain_Map]
  event TooltipAndHoverDetails : Other
]

component uiCo_Open_Store_Count_by_Open_Month_and_Chain_BarChart : InteractiveChart : InteractiveBarChart [
  dataBinding dec_Sales
  // Chart axes
  part OpenMonth "Open Month" : Field : X_Axis [dataAttributeBinding _Time.Month]
  part Chain "Chain" : Field : Y_Axis [dataAttributeBinding Stores.Chain]
  part OpenStoreCount "Open Store Count" : Field : Y_Axis [dataAttributeBinding Stores.OpenStoreCount]

  event TooltipAndHoverDetails : Other
  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_Open_Store_Count_by_Open_Month_and_Chain_BarChart]
]

component uiCo_Sales_Per_Sq_Ft_by_Name_BarChart : InteractiveChart : InteractiveBarChart [
  dataBinding dec_Sales
  // Chart axes
  part StoreName "Store Name" : Field : X_Axis [dataAttributeBinding Stores.Name]
  part SalesPerSqFt "Sales Per Sq Ft" : Field : Y_Axis [dataAttributeBinding Sales.SalesPerSqFt]

  event TooltipAndHoverDetails : Other
  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_Sales_Per_Sq_Ft_by_Name_BarChart]
]

component uiCo_This_Year_Sales_by_FiscalMonth_LineChart : InteractiveChart : InteractiveLineChart [
  dataBinding dec_Sales
  // Chart axes
  part FiscalMonth "Fiscal Month" : Field : X_Axis [dataAttributeBinding _Time.FiscalMonth]
  part ThisYearSales "This Year Sales" : Field : Y_Axis [dataAttributeBinding Sales.TotalSalesTY]

  event TooltipAndHoverDetails : Other
  event RealTimeDataUpdate : Submit : Submit_Update [navigationFlowTo uiCo_This_Year_Sales_by_FiscalMonth_LineChart]
]

UIContainer page_Overview "Overview" : Window : Page [
    // Visual elements
    component uiCo_This_Year_Sales_by_Chain_PieChart
    component uiCo_New_Stores_Card
    component uiCo_Total_Stores_Card
    component uiCo_Total_Sales_Variance_by_FiscalMonth_and_District_Manager_BarChart
    component uiCo_This_Year_Sales_by_PostalCode_and_Store_Type_Map
    component uiCo_Total_Sales_Variance_Percentage_Sales_Per_Sq_Ft_and_This_Year_Sales_by_District_and_District_ScatterPlot
]

UIContainer page_District_Monthly_Sales "Distric Monthly Sales" : Window : Page [
    // Visual elements
    component uiCo_Total_Sales_Variance_Percentage_by_FiscalMonth_BarChart
    component uiCo_This_Year_Sales_by_StoreNumberName_BarChart
    component uiCo_Last_Year_Sales_and_This_Year_Sales_by_FiscalMonth_AreaChart
    component uiCo_Total_Sales_Variance_Percentage_Avg_Unit_TY_and_This_Year_Sales_by_Category_and_Category_ScatterPlot
    // Filter
    component fi_District_Manager_Filter
]

UIContainer page_New_Stores "New Stores" : Window : Page [
    // Visual elements
    component uiCo_This_Year_Sales_by_City_and_Chain_Map
    component uiCo_Open_Store_Count_by_Open_Month_and_Chain_BarChart
    component uiCo_Sales_Per_Sq_Ft_by_Name_BarChart
    component uiCo_This_Year_Sales_by_FiscalMonth_LineChart
    // Filter
    component fi_New_Stores_Name_Filter
]
