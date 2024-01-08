Package bi

System bi_types: Application [ isReusable ] 

// BI-Extensions.asl
// A) Data Entities SubTypes

DataEntitySubType BI_Dimension
DataEntitySubType BI_Fact

// B) Data Entities Attribute Types

DataAttributeType UUID 
DataAttributeType _Dimension

// C) UIContainers SubTypes

UIContainerSubType Dashboard 
UIContainerSubType Page 

// D) UIComponents Types

UIComponentType Card
UIComponentType Chart
UIComponentType Filter

// E) UIComponents Sub Types

// E.1) Tables

UIComponentSubType Table

// E.2) Charts

UIComponentSubType LineChart
UIComponentSubType PieChart
UIComponentSubType BarChart
UIComponentSubType AreaChart
UIComponentSubType ScatterPlot
UIComponentSubType GeographicalMap

// E.3) Filters

UIComponentSubType Dropdown
UIComponentSubType Range
UIComponentSubType Search

// F) UIComponents Parts Sub Types

// F.1) Tables

UIComponentPartSubType Column

// F.2) Charts

UIComponentPartSubType X_Axis
UIComponentPartSubType Y_Axis
UIComponentPartSubType Value
UIComponentPartSubType Area
UIComponentPartSubType Legend
UIComponentPartSubType Label
UIComponentPartSubType Location
UIComponentPartSubType Longitude
UIComponentPartSubType Latitude

// F.3) Filters

UIComponentPartSubType Option

// G) OLAP Operations
ActionType BI_Slice
ActionType BI_Dice
ActionType BI_DrillDown
ActionType BI_Rollup
ActionType BI_Pivot

// H) Use Case Types

UseCaseType BIOperation
UseCaseSubType DataQuerying
UseCaseSubType DataReport
UseCaseSubType DataImport
UseCaseSubType DataExport
