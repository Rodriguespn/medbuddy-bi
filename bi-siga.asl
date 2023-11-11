Package bi_siga

Import bi.bi_types


System bisiga: Application 

/*****************************
    Multi-dimensional model
*****************************/

// Data Enumerations
DataEnumeration Gender values (Male, Female)
DataEnumeration States values (Booked, Held, Cancelled)
DataEnumeration InstitutionTypes values (HealthCentre, Hospital)

// Dimensions
DataEntity e_City "City" : Reference : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute latitude "Latitude" : Decimal [constraints (NotNull)]
  attribute longitude "Longitude" : Decimal [constraints (NotNull)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
]

DataEntity e_Patient "Patient" : Master : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute nhs_number "NHS Number" : Integer [constraints (NotNull)]
  attribute age "Age" : Integer [constraints (NotNull)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute gender "Gender" : DataEnumeration Gender [constraints (NotNull)]
  attribute residence "Residence" : _Dimension [constraints (NotNull ForeignKey(e_City))]
]

DataEntity e_Institution "Intitution" : Master : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute Code "Code" : String(50) [constraints (NotNull)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute latitude "Latitude" : Decimal [constraints (NotNull)]
  attribute longitude "Longitude" : Decimal [constraints (NotNull)]
  attribute city "City" : _Dimension [constraints (NotNull ForeignKey(e_City))]
  attribute type "Type" : DataEnumeration InstitutionTypes [constraints (NotNull)]
]

DataEntity e_RequestState "Request State" : Reference : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute is_final "Is Final" : Boolean [constraints (NotNull)]
  attribute is_initial "Is Initial" : Boolean [constraints (NotNull)]
  attribute Name "Name" : DataEnumeration States [constraints (NotNull)]
]

DataEntity e_Time "Time" : Reference: BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute date "Date" : Date [constraints (NotNull)]
  attribute day "Day" : Integer [constraints (NotNull)]
  attribute month "Month" : Integer [constraints (NotNull)]
  attribute quarter "Quarter" : Integer [constraints (NotNull)]
  attribute year "Year" : Integer [constraints (NotNull)]
]

// Facts
DataEntity e_AppointmentRequest "Appointment Request" : Transaction : BI_Fact [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute institution "Institution" : _Dimension  [constraints (NotNull ForeignKey(e_Institution))]
  attribute patient "Patient" : _Dimension [constraints (NotNull ForeignKey(e_Patient))]
  attribute _state "Request State" : _Dimension [constraints (NotNull ForeignKey(e_RequestState))]
  attribute scheduled_date "Scheduled Date" : _Dimension [constraints (NotNull ForeignKey(e_Time))]
  attribute closed_date "Closed Date" : _Dimension [constraints (ForeignKey(e_Time))]
  attribute maximum_response_time "Maximum Response Time" : Integer [constraints (NotNull)]
  attribute actual_response_time "Actual Response Time" : Integer
  attribute closed "Is closed" : Boolean [constraints (NotNull)]
  attribute CountAppointments "Count of Appointments" : Integer [formula details: count (e_AppointmentRequest)]
  attribute CountCancelledAppointments "Count of Cancelled Appointments" : Integer [formula details: count (e_AppointmentRequest) tag (name "expression" value "count(if(was_cancelled = True))")] 
  attribute CancellationRate "Cancellation Rate" : Decimal [formula arithmetic (CountCancelledAppointments / CountAppointments)]
  attribute AvgWaitingTime "Average Waiting Time" : Decimal [tag (name "expression" value "average(actual_waiting_time)")]
  attribute MinDate "Minimum Date" : Date [tag (name "expression" value "min(time.date)")]
  attribute MaxDate "Maximum Date" : Date [tag (name "expression" value "max(time.date)")]
]


DataEntityCluster dec_AppointmentRequests "Appointment Requests Cluster" : Transaction [
  main e_AppointmentRequest 
  uses e_Time, e_Patient, e_Institution, e_City
  description "Data entity cluster to represent the connections between the Appointments fact with the dimension"
]    

/***************************** 
          Use Cases
*****************************/
Actor a_National_Level_Data_Analyst " National Level Data Analyst " : User [ description "User with permitions to visualize the SIGA-BI system at a national level" ]
Actor a_Institution_Level_Data_Analyst  "Institution Level Data Analyst " : User [ description "User with permitions to visualize the SIGA-BI system at an intitution level" ]

// Institution Page Use Cases
// Institution Page Use Cases
UseCase uc_Analysis_Appointments_National_Level : BI_Analysis [
  actorInitiates a_National_Level_Data_Analyst
  dataEntity dec_AppointmentRequests

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot 

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificCityAndYear" value "Dimensions:'e_Time, e_Institution, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByInstitutionCity" value "Dimensions:'e_Institution'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByInstitution" value "Dimensions:'e_Institution'")

  description "Displays the appointment data by institution at a national level"
]

UseCase uc_Analysis_Appointments_Institution_Level : BI_Analysis [
  actorInitiates a_Institution_Level_Data_Analyst
  dataEntity dec_AppointmentRequests

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot 

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")

  description "Only displays the appointment data at a single institution level"
]

// Patient Page Use Cases
UseCase uc_AnalysisAppointmentsPatientOnNationalLevel : BI_Analysis [
  actorInitiates a_National_Level_Data_Analyst
  dataEntity dec_AppointmentRequests
  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificPatientResidenceCityAndYear" value "Dimensions:'e_Time, e_Patient, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByGender" value "Dimensions:'e_Patient'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByAge" value "Dimensions:'e_Patient'")

  description "Displays the appointment data by patient at a national level"
]
 
UseCase uc_AnalysisAppointmentsInstitutionOnNationalLevel : BI_Analysis [
  actorInitiates a_Institution_Level_Data_Analyst
  dataEntity dec_AppointmentRequests

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificPatientResidenceCityAndYear" value "Dimensions:'e_Time, e_Patient, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByGender" value "Dimensions:'e_Patient'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByAge" value "Dimensions:'e_Patient'")

  description "Only displays the appointment data by patient at a single institution level"
]

/*****************************
	UI Elements
*****************************/

// Time Range Filter
component uiCo_TimeFilter "Select Time Range" : Filter : Range [
  dataBinding dec_AppointmentRequests
    
  part minDate "Min Date" : Field : Option [dataAttributeBinding e_AppointmentRequest.MinDate]
  part maxDate "Max Date" : Field : Option [dataAttributeBinding e_AppointmentRequest.MaxDate]

  // Submit Button
  event e_ApplyFilter : Submit : Submit_Update [tag (name "Time Slice" value "Slice Appointments by the selected time range")]
  event e_ResetFilter : Submit : Submit_Update [tag (name "Reset" value "Clear the time filter")]
]

// D.2. Tables:

// Patient Table 
component uiCo_PatientTable "Patient Details" : List : Table [
  dataBinding dec_AppointmentRequests
    
  // The data table columns
  part id "ID" : Field : Column [dataAttributeBinding e_Patient.id]
  part nhs_number "NHS Number" : Field : Column [dataAttributeBinding e_Patient.nhs_number]
  part Name "Name" : Field : Column [dataAttributeBinding e_Patient.Name]
  part gender "Gender" : Field : Column [dataAttributeBinding e_Patient.gender]
  part CountAppointments "Number of Appointments" : Field : Column [dataAttributeBinding e_AppointmentRequest.CountAppointments]
]

// Institution Table 
component uiCo_InstitutionTable "Institution Details" : List : Table [
  dataBinding dec_AppointmentRequests
    
  // The data table columns
  part id "ID" : Field : Column [dataAttributeBinding e_Institution.id]
  part Code "Code" : Field : Column [dataAttributeBinding e_Institution.Code]
  part Name "Name" : Field : Column [dataAttributeBinding e_Institution.Name]
  part latitude "Latitude" : Field : Column [dataAttributeBinding e_Institution.latitude]
  part longitude "Longitude" : Field : Column [dataAttributeBinding e_Institution.longitude]
  part city "City" : Field : Column [dataAttributeBinding e_Institution.city]
  part AvgWaitingTime "Average Waiting Time" : Field : Column [dataAttributeBinding e_AppointmentRequest.AvgWaitingTime]
]

// D.3. Charts:

// Bar Chart
component uiCo_AgeBarChart "Age Distribution" : InteractiveChart : InteractiveBarChart [
  dataBinding dec_AppointmentRequests
    
  // The chart axes
  part age "Age" : Field : X_Axis [dataAttributeBinding e_Patient.age]
  part CountAppointments "Number of Appointments" : Field : Y_Axis [dataAttributeBinding e_AppointmentRequest.CountAppointments]

  event TooltipAndHoverDetails : Other
]

// Pie Chart
component uiCo_GenderChart "Gender Distribution" : InteractiveChart : InteractivePieChart [
  dataBinding dec_AppointmentRequests
    
  // The chart segments
  part gender "Gender" : Field : Label [dataAttributeBinding e_Patient.gender]
  part numberOfAppointments "Number of Appointments" : Field : Value [dataAttributeBinding e_AppointmentRequest.CountAppointments]

  event TooltipAndHoverDetails : Other
]

// Line Chart
component uiCo_CancellationRateChart "Cancellation Rate by Institution" : InteractiveChart : InteractiveLineChart [
  dataBinding dec_AppointmentRequests
    
  // The chart axes
  part type "Institution Type" : Field : X_Axis [dataAttributeBinding e_Institution.type]
  part CountAppointments "Number of Appointments" : Field : Y_Axis [dataAttributeBinding e_AppointmentRequest.CountAppointments]

  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_CancellationRateChart]
  event RealTimeDataUpdate : Submit : Submit_Update [navigationFlowTo uiCo_CancellationRateChart]
  event TooltipAndHoverDetails : Other
]

// Scatter Plot
component uiCo_PatientAppointmentScatter "Appointment Scatter Plot by Patient Residence" : InteractiveChart : InteractiveScatterPlot [
  dataBinding dec_AppointmentRequests
    
  // The chart axes
  part CountAppointments "Number of Appointments" : Field : X_Axis [dataAttributeBinding e_AppointmentRequest.CountAppointments]
  part AvgWaitingTime "Average Waiting Time" : Field : Y_Axis [dataAttributeBinding e_AppointmentRequest.AvgWaitingTime]
    
  // The label
  part residence "Patient Residence" : Field : Label [dataAttributeBinding e_Patient.residence]

  event TooltipAndHoverDetails : Other
]

// Location Map
component uiCo_LocationMap "Appointments by Institution Locations" : InteractiveChart : InteractiveGeographicalMap [
  dataBinding dec_AppointmentRequests
   
  // The chart axes
  part latitude "Latitude" : Field : Latitude [dataAttributeBinding e_Institution.latitude]
  part longitude "Longitude" : Field : Longitude [dataAttributeBinding e_Institution.longitude]
   
  // The value
  part CountAppointments "Number of Appointments" : Field : Value [dataAttributeBinding e_AppointmentRequest.CountAppointments] 

  event ZoomAndPanUpdate : Submit : Submit_Update [navigationFlowTo uiCo_CancellationRateChart]
  event RealTimeDataUpdate : Submit : Submit_Update [navigationFlowTo uiCo_CancellationRateChart]
  event TooltipAndHoverDetails : Other
]

// D.4. Pages:

// Patient Overview Page
UIContainer uiCo_PatientOverviewPage "Patient Overview Page" : Window : Page [
  // Visual elements
  component uiCo_PatientTable
  component uiCo_GenderChart
  component uiCo_AgeBarChart
  component uiCo_PatientAppointmentScatter
    
  // Filters
  component uiCo_TimeFilter
    
  // Buttons 
  event ev_InstitutionPageButton : Submit : Submit_Back [navigationFlowTo uiCo_InstitutionOverviewPage]
]

// Institution Overview Page
UIContainer uiCo_InstitutionOverviewPage "Institution Overview Page" : Window : Page [
  // Visual elements
  component uiCo_InstitutionTable
  component uiCo_CancellationRateChart
  component uiCo_LocationMap
    
  // Filters
  component uiCo_TimeFilter
    
  // Buttons
  event ev_PatientPageButton : Submit : Submit_Back [navigationFlowTo uiCo_PatientOverviewPage]
]
