Package bi

System bi_types: Application [ isReusable ] 

/* Data Entitites SubTypes */
DataEntitySubType BI_Dimension [description "Dimension data entity sub type"]
DataEntitySubType BI_Fact [description "Fact data entity sub type"]

/* Data Entities Attribute Types */
DataAttributeType UUID 
DataAttributeType _Dimension [description "Used to reference a Dimension on a data entity attribute"]

/* UIContainers SubTypes */
UIContainerSubType Dashboard 
UIContainerSubType Page 

/* UIComponents Types */
UIComponentType Card
UIComponentType InteractiveChart
UIComponentType Filter

/*UIComponents Sub Types*/
// Tables
UIComponentSubType Table

// Charts
UIComponentSubType InteractiveLineChart
UIComponentSubType InteractivePieChart
UIComponentSubType InteractiveBarChart
UIComponentSubType InteractiveAreaChart
UIComponentSubType InteractiveScatterPlot
UIComponentSubType InteractiveGeographicalMap

// Filters
UIComponentSubType Dropdown
UIComponentSubType Range
UIComponentSubType Search

/* UIComponents Parts Sub Types */
// Tables
UIComponentPartSubType Column

// Charts
UIComponentPartSubType X_Axis
UIComponentPartSubType Y_Axis
UIComponentPartSubType Value
UIComponentPartSubType Area
UIComponentPartSubType Legend
UIComponentPartSubType Label
UIComponentPartSubType Location
UIComponentPartSubType Longitude
UIComponentPartSubType Latitude

// Filters
UIComponentPartSubType Option

/* OLAP Operations */
ActionType BI_Slice [ description "This is a Slice operation"]
ActionType BI_Dice [ description "This is a Dice operation"]
ActionType BI_DrillDown [ description "This is a Drill-down operation"]
ActionType BI_Rollup [ description "This is a Roll-up Operation"]
ActionType BI_Pivot [ description "This is a Pivot operation"]

/* Use Cases Types */
UseCaseType BI_Analysis [ description "Represents a data analytical use case"]
