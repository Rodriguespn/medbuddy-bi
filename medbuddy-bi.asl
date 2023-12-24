Package medbuddy_bi

Import bi.bi_types


System medbuddy_bi: Application 

DataEnumeration Gender values (Male, Female)
DataEnumeration States values (Booked, Held, Cancelled)
DataEnumeration InstitutionTypes values (HealthCentre, Hospital)

DataEntity e_City "City" : Reference : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute latitude "Latitude" : Decimal [constraints (NotNull)]
  attribute longitude "Longitude" : Decimal [constraints (NotNull)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  description "This dimension represents the details of a city" ]

DataEntity e_Patient "Patient" : Master : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute nhs_number "NHS Number" : Integer [constraints (NotNull)]
  attribute age "Age" : Integer [constraints (NotNull)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute gender "Gender" : DataEnumeration Gender [constraints (NotNull)]
  attribute residence "Residence" : _Dimension [constraints (NotNull ForeignKey(e_City))]
  description "This dimension represents the details of a patient" ]

DataEntity e_Institution "Institution" : Master : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute Code "Code" : String(50) [constraints (NotNull)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute latitude "Latitude" : Decimal [constraints (NotNull)]
  attribute longitude "Longitude" : Decimal [constraints (NotNull)]
  attribute city "City" : _Dimension [constraints (NotNull ForeignKey(e_City))]
  attribute type "Type" : DataEnumeration InstitutionTypes [constraints (NotNull)] ]

DataEntity e_RequestState "Request State" : Reference : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute is_final "Is Final" : Boolean [constraints (NotNull)]
  attribute is_initial "Is Initial" : Boolean [constraints (NotNull)]
  attribute Name "Name" : DataEnumeration States [constraints (NotNull)]
  description "This dimension represents the details of a request state" ]

DataEntity e_Time "Time" : Reference: BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute date "Date" : Date [constraints (NotNull)]
  attribute day "Day" : Integer [constraints (NotNull)]
  attribute month "Month" : Integer [constraints (NotNull)]
  attribute quarter "Quarter" : Integer [constraints (NotNull)]
  attribute year "Year" : Integer [constraints (NotNull)]
  description "This dimension represents the details of the time" ]

DataEntity e_AppointmentRequest "Appointment Request" : Transaction : BI_Fact [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute institution "Institution" : _Dimension  [constraints (NotNull ForeignKey(e_Institution))]
  attribute patient "Patient" : _Dimension [constraints (NotNull ForeignKey(e_Patient))]
  attribute _state "Request State" : _Dimension [constraints (NotNull ForeignKey(e_RequestState))]
  attribute scheduled_date "Scheduled Date" : _Dimension [constraints (NotNull ForeignKey(e_Time))]
  attribute closed_date "Closed Date" : _Dimension [constraints (ForeignKey(e_Time))]
  attribute closed "Is closed" : Boolean [constraints (NotNull)]
  attribute maximum_response_time "Maximum Response Time" : Integer [constraints (NotNull)]
  attribute actual_response_time "Actual Response Time" : Integer
  attribute CountAppointments "Count of Appointments" : Integer [formula details: count (e_AppointmentRequest)]
  attribute CountCancelledAppointments "Count of Cancelled Appointments" : Integer [formula details: count (if(e_AppointmentRequest.was_cancelled = True))] 
  attribute CancellationRate "Cancellation Rate" : Decimal [formula arithmetic (CountCancelledAppointments / CountAppointments)]
  attribute AvgWaitingTime "Average Waiting Time" : Decimal [formula details: average(actual_waiting_time))]
  attribute MinDate "Minimum Date" : Date [formula details: min(time.date)]
  attribute MaxDate "Maximum Date" : Date [formula details: max(time.date)] ]

B.4. Data Entities Clusters:

DataEntityCluster dec_Appointments "Appointments Cluster" : Transaction [
  main e_AppointmentRequest 
  uses e_Time, e_Patient, e_Institution, e_City
  description "Data entity cluster to represent the connections between the Appointments fact with the dimension" ]

Actor a_National_Level_Data_Analyst "National Level Data Analyst" : User [ description "User with permitions to visualise the application at a national level" ]
Actor a_Institution_Manager "Institution Manager" : User [ description "User with permitions to visualise the application at an intitution level" ]

// Institution Page Use Cases
UseCase uc_Analysis_Appointments_National_Level : BIInteraction : DataAnalysis [
  actorInitiates a_National_Level_Data_Analyst
  dataEntity dec_AppointmentRequests

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown 

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificCityAndYear" value "Dimensions:'e_Time, e_Institution, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByInstitutionCity" value "Dimensions:'e_Institution'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByInstitution" value "Dimensions:'e_Institution'")

  description "Displays the appointment data by institution at a national level" ]

UseCase uc_Analysis_Appointments_Institution_Level : BIInteraction : DataAnalysis [
  actorInitiates a_Institution_Level_Data_Analyst
  dataEntity dec_AppointmentRequests

  actions BI_Slice

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")

  description "Only displays the appointment data at a single institution level" ]
// Patient Page Use Cases
UseCase uc_AnalysisAppointmentsPatientOnNationalLevel : BIInteraction : DataAnalysis [
  actorInitiates a_National_Level_Data_Analyst
  dataEntity dec_AppointmentRequests

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificPatientResidenceCityAndYear" value "Dimensions:'e_Time, e_Patient, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByGender" value "Dimensions:'e_Patient'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByAge" value "Dimensions:'e_Patient'")

  description "Displays the appointment data by patient at a national level" ]
 
UseCase uc_AnalysisAppointmentsInstitutionOnNationalLevel : BIInteraction : DataAnalysis [
  actorInitiates a_Institution_Level_Data_Analyst
  dataEntity dec_AppointmentRequests

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificPatientResidenceCityAndYear" value "Dimensions:'e_Time, e_Patient, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByGender" value "Dimensions:'e_Patient'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByAge" value "Dimensions:'e_Patient'")

  description "Only displays the appointment data by patient at a single institution level" ]

// Time Range Filter
component uiCo_TimeFilter "Select Time Range" : Filter : Range [
  dataBinding dec_AppointmentRequests
    
  part minDate "Min Date" : Field : Option [dataAttributeBinding e_AppointmentRequest.MinDate]
  part maxDate "Max Date" : Field : Option [dataAttributeBinding e_AppointmentRequest.MaxDate]
  // Submit Button
  event e_ApplyFilter : Submit : Submit_Update [tag (name "Time Slice" value "Slice Appointments by the selected time range")]
  event e_ResetFilter : Submit : Submit_Update [tag (name "Reset" value "Clear the time filter")] ]

// Patient Table 
component uiCo_PatientTable "Patient Details" : List : Table [
  dataBinding dec_AppointmentRequests
  // The data table columns
  part id "ID" : Field : Column [dataAttributeBinding e_Patient.id]
  part nhs_number "NHS Number" : Field : Column [dataAttributeBinding e_Patient.nhs_number]
  part Name "Name" : Field : Column [dataAttributeBinding e_Patient.Name]
  part gender "Gender" : Field : Column [dataAttributeBinding e_Patient.gender]
  part CountAppointments "Number of Appointments" : Field : Column [dataAttributeBinding e_AppointmentRequest.CountAppointments] ]
// Institution Table 
component uiCo_InstitutionTable "Institution Details" : List : Table [
  dataBinding dec_AppointmentRequests
  // The table columns
  part id "ID" : Field : Column [dataAttributeBinding e_Institution.id]
  part Code "Code" : Field : Column [dataAttributeBinding e_Institution.Code]
  part Name "Name" : Field : Column [dataAttributeBinding e_Institution.Name]
  part latitude "Latitude" : Field : Column [dataAttributeBinding e_Institution.latitude]
  part longitude "Longitude" : Field : Column [dataAttributeBinding e_Institution.longitude]
  part city "City" : Field : Column [dataAttributeBinding e_Institution.city]
  part AvgWaitingTime "Average Waiting Time" : Field : Column [dataAttributeBinding e_AppointmentRequest.AvgWaitingTime] 
]

// Bar Chart
component uiCo_AgeBarChart "Age Distribution" : InteractiveChart : InteractiveBarChart [
  dataBinding dec_AppointmentRequests
  // The chart axes
  part age "Age" : Field : X_Axis [dataAttributeBinding e_Patient.age]
  part CountAppointments "Number of Appointments" : Field : Y_Axis [dataAttributeBinding e_AppointmentRequest.CountAppointments]

  event TooltipAndHoverDetails : Other ]
// Pie Chart
component uiCo_GenderChart "Gender Distribution" : InteractiveChart : InteractivePieChart [
  dataBinding dec_AppointmentRequests
  // The chart segments
  part gender "Gender" : Field : Label [dataAttributeBinding e_Patient.gender]
  part numberOfAppointments "Number of Appointments" : Field : Value [dataAttributeBinding e_AppointmentRequest.CountAppointments]

  event TooltipAndHoverDetails : Other ]
// Line Chart
component uiCo_CancellationRateChart "Cancellation Rate by Institution" : InteractiveChart : InteractiveLineChart [
  dataBinding dec_AppointmentRequests
  // The chart axes
  part type "Institution Type" : Field : X_Axis [dataAttributeBinding e_Institution.type]
  part CountAppointments "Number of Appointments" : Field : Y_Axis [dataAttributeBinding e_AppointmentRequest.CountAppointments]

  event DrillDown : Submit : Submit_Update [navigationFlowTo uiCo_CancellationRateChart]
  event RealTimeDataUpdate : Submit : Submit_Update [navigationFlowTo uiCo_CancellationRateChart]
  event TooltipAndHoverDetails : Other ]
// Scatter Plot
component uiCo_PatientAppointmentScatter "Appointment Scatter Plot by Patient Residence" : InteractiveChart : InteractiveScatterPlot [
  dataBinding dec_AppointmentRequests 
  // The chart axes
  part CountAppointments "Number of Appointments" : Field : X_Axis [dataAttributeBinding e_AppointmentRequest.CountAppointments]
  part AvgWaitingTime "Average Waiting Time" : Field : Y_Axis [dataAttributeBinding e_AppointmentRequest.AvgWaitingTime]
  // The label
  part residence "Patient Residence" : Field : Label [dataAttributeBinding e_Patient.residence]

  event TooltipAndHoverDetails : Other ]
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
  event TooltipAndHoverDetails : Other ]


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
