Package medbuddy_bi

Import bi.bi_types


System medbuddy_bi: Application 

// A) Multidimensional model 

// A.1. Data Enumerations:

DataEnumeration Gender values (Male, Female)
DataEnumeration States values (Booked, Held, Cancelled)
DataEnumeration InstitutionTypes values (HealthCentre, Hospital)

// A.2. Dimensions:

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
  attribute city "City" : _Dimension [constraints (NotNull ForeignKey(e_City))]
  description "This dimension represents the details of a patient" ]

DataEntity e_Institution "Institution" : Master : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute Code "Code" : String(50) [constraints (NotNull)]
  attribute Name "Name" : String(50) [constraints (NotNull)]
  attribute latitude "Latitude" : Decimal [constraints (NotNull)]
  attribute longitude "Longitude" : Decimal [constraints (NotNull)]
  attribute city "City" : _Dimension [constraints (NotNull ForeignKey(e_City))]
  attribute type "Type" : DataEnumeration InstitutionTypes [constraints (NotNull)] ]

DataEntity e_AppointmentsState "Request State" : Reference : BI_Dimension [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute is_Final "Is Final" : Boolean [constraints (NotNull)]
  attribute is_Initial "Is Initial" : Boolean [constraints (NotNull)]
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

// A.3. Facts:

DataEntity e_Appointment "Appointment Request" : Transaction : BI_Fact [
  attribute id "UUID" : UUID [constraints (PrimaryKey NotNull Unique)]
  attribute institution "Institution" : _Dimension  [constraints (NotNull ForeignKey(e_Institution))]
  attribute patient "Patient" : _Dimension [constraints (NotNull ForeignKey(e_Patient))]
  attribute state "Request State" : _Dimension [constraints (NotNull ForeignKey(e_AppointmentsState))]
  attribute scheduledDate "Scheduled Date" : _Dimension [constraints (NotNull ForeignKey(e_Time))]
  attribute closedDate "Closed Date" : _Dimension [constraints (ForeignKey(e_Time))]
  attribute closed "Is closed" : Boolean [constraints (NotNull)]
  attribute cancelled "Is cancelled" : Boolean [constraints (NotNull)]
  attribute maximumResponseTime "Maximum Response Time" : Integer [constraints (NotNull)]
  attribute actualResponseTime "Actual Response Time" : Integer
  attribute countAppointments "Count of Appointment Requests" : Integer [formula details: count (e_Appointment)]
  attribute countCancelledAppointments "Count of Cancelled Appointment Requests" : Integer [formula details: count(e_Appointment) tag (name "expression" value "count(if(e_Appointment.cancelled = True))")] 
  attribute cancellationRate "Cancellation Rate" : Decimal [formula arithmetic (countCancelledAppointments / countAppointments)]
  attribute avgWaitingTime "Average Waiting Time" : Decimal [formula details: count(e_Appointment) tag (name "expression" value "average(actualResponseTime)")]
  attribute minDate "Minimum Date" : Date [formula details: count(e_Appointment) tag (name "expression" value "min(scheduledDate)")]
  attribute maxDate "Maximum Date" : Date [formula details: count(e_Appointment) tag (name "expression" value "max(scheduledDate)")] ]

//A.4. Data Entities Clusters:

DataEntityCluster dec_Appointments "Appointments Cluster" : Transaction [
  main e_Appointment 
  uses e_Time, e_Patient, e_Institution, e_City
  description "Data entity cluster to represent the Appointment fact" ]

// B) Use Cases

// B.1. Actors:

Actor a_NationalLevelDataAnalyst "National Level Data Analyst" : User [ description "User with permissions to visualise the data at a national level" ]
Actor a_InstitutionLevelDataAnalyst "Institution Data Analyst" : User [ description "User with permissions to visualise the data at an institution level" ]

// B.2. Use Cases:

UseCase uc_AnalysisAppointmentsNationalLevel : BIOperation : DataQuerying [
  actorInitiates a_NationalLevelDataAnalyst
  dataEntity dec_Appointments

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown 

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificCityAndYear" value "Dimensions:'e_Time, e_Institution, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByInstitutionCity" value "Dimensions:'e_Institution'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByInstitution" value "Dimensions:'e_Institution'")

  description "Displays the appointment data by institution at a national level" ]

UseCase uc_Analysis_Appointments_InstitutionLevel : BIOperation : DataQuerying [
  actorInitiates a_InstitutionLevelDataAnalyst
  dataEntity dec_Appointments

  actions BI_Slice

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")

  description "Only displays the appointment data at a single institution level" ]

UseCase uc_AnalysisAppointmentsPatientOnNationalLevel : BIOperation : DataQuerying [
  actorInitiates a_NationalLevelDataAnalyst
  dataEntity dec_Appointments

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificPatientResidenceCityAndYear" value "Dimensions:'e_Time, e_Patient, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByGender" value "Dimensions:'e_Patient'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByAge" value "Dimensions:'e_Patient'")

  description "Displays the appointment data by patient at a national level" ]
 
UseCase uc_AnalysisAppointmentsInstitutionOnNationalLevel : BIOperation : DataQuerying [
  actorInitiates a_InstitutionLevelDataAnalyst
  dataEntity dec_Appointments

  actions BI_Slice, BI_Dice, BI_Rollup, BI_DrillDown, BI_Pivot

  tag (name "BI-Action:BI_Slice:ScheduledAppointmentsInSpecificYear" value "Dimensions:'e_Time'")
  tag (name "BI-Action:BI_Dice:ScheduledAppointmentsBySpecificPatientResidenceCityAndYear" value "Dimensions:'e_Time, e_Patient, e_City'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByGender" value "Dimensions:'e_Patient'")
  tag (name "BI-Action:BI_RollUp:AppointmentsByAge" value "Dimensions:'e_Patient'")

  description "Only displays the appointment data by patient at a single institution level" ]

// C) User Interface specification

// Patient Overview Page
UIContainer uiCo_PatientOverviewPage "Patient Overview Page" : Window : Page [
  component uiCo_PatientTable "Patient Details" : List : Table [
    dataBinding dec_Appointments
    // The data table columns
    part Id "ID" : Field : Column [dataAttributeBinding e_Patient.id]
    part Nhs_number "NHS Number" : Field : Column [dataAttributeBinding e_Patient.nhs_number]
    part Name "Name" : Field : Column [dataAttributeBinding e_Patient.Name]
    part Gender "Gender" : Field : Column [dataAttributeBinding e_Patient.gender]
    part CountAppointments "Number of Appointment Requests" : Field : Column [dataAttributeBinding e_Appointment.countAppointments] 
  ]

  component uiCo_GenderChart "Gender Distribution" : Chart : PieChart [
    dataBinding dec_Appointments
    // The chart segments
    part Gender "Gender" : Field : Label [dataAttributeBinding e_Patient.gender]
    part NumberOfAppointments "Number of Appointment Requests" : Field : Value [dataAttributeBinding e_Appointment.countAppointments]

    event e_ShowHoverDetails : Submit : Submit_View 
  ]

  component uiCo_AgeBarChart "Age Distribution" : Chart : BarChart [
    dataBinding dec_Appointments
    // The chart axes
    part Age "Age" : Field : X_Axis [dataAttributeBinding e_Patient.age]
    part CountAppointments "Number of Appointment Requests" : Field : Y_Axis [dataAttributeBinding e_Appointment.countAppointments]

    event e_ShowHoverDetails : Submit : Submit_View 
  ]

  component uiCo_PatientAppointmentScatter "Appointment Scatter Plot by Patient Residence" : Chart : ScatterPlot [
    dataBinding dec_Appointments 
    // The chart axes
    part CountAppointments "Number of Appointment Requests" : Field : X_Axis [dataAttributeBinding e_Appointment.countAppointments]
    part AvgWaitingTime "Average Waiting Time" : Field : Y_Axis [dataAttributeBinding e_Appointment.avgWaitingTime]
    // The label
    part City "Patient City" : Field : Label [dataAttributeBinding e_Patient.city]

    event e_ShowHoverDetails : Submit : Submit_View 
  ]
  // Filters
  component uiCo_TimeFilter "Select Time Range" : Filter : Range [
    dataBinding dec_Appointments
    
    part MinDate "Min Date" : Field : Option [dataAttributeBinding e_Appointment.minDate]
    part MaxDate "Max Date" : Field : Option [dataAttributeBinding e_Appointment.maxDate]
    // Submit Button
    event e_ApplyFilter : Submit : Submit_Update [tag (name "Time Slice" value "Slice Appointments by the selected time range")]
    event e_ResetFilter : Submit : Submit_Update [tag (name "Reset" value "Clear the time filter")] 
  ]
  // Buttons 
  event e_InstitutionPageButton : Submit : Submit_Back [navigationFlowTo uiCo_InstitutionOverviewPage]
]
// Institution Overview Page
UIContainer uiCo_InstitutionOverviewPage "Institution Overview Page" : Window : Page [
  component uiCo_InstitutionTable "Institution Details" : List : Table [
    dataBinding dec_Appointments
    // The table columns
    part Id "ID" : Field : Column [dataAttributeBinding e_Institution.id]
    part Code "Code" : Field : Column [dataAttributeBinding e_Institution.code]
    part Name "Name" : Field : Column [dataAttributeBinding e_Institution.Name]
    part Latitude "Latitude" : Field : Column [dataAttributeBinding e_Institution.latitude]
    part Longitude "Longitude" : Field : Column [dataAttributeBinding e_Institution.longitude]
    part City "City" : Field : Column [dataAttributeBinding e_Institution.city]
    part AvgWaitingTime "Average Waiting Time" : Field : Column [dataAttributeBinding e_Appointment.avgWaitingTime] 
  ]

  component uiCo_CancellationRateChart "Cancellation Rate by Institution" : Chart : LineChart [
    dataBinding dec_Appointments
    // The chart axes
    part Type "Institution Type" : Field : X_Axis [dataAttributeBinding e_Institution.type]
    part CountAppointments "Number of Appointment Requests" : Field : Y_Axis [dataAttributeBinding e_Appointment.countAppointments]

    event e_DrillDown : Submit : Submit_Update
    event e_RollUp : Submit : Submit_Update
    event e_DataUpdate : Submit : Submit_Update
    event e_ShowHoverDetails : Submit : Submit_View 
  ]
  
  component uiCo_LocationMap "Appointment Requests by Institution Locations" : Chart : GeographicalMap [
    dataBinding dec_Appointments
    // The chart axes
    part Latitude "Latitude" : Field : Latitude [dataAttributeBinding e_Institution.latitude]
    part Longitude "Longitude" : Field : Longitude [dataAttributeBinding e_Institution.longitude]
    // The value
    part CountAppointments "Number of Appointment Requests" : Field : Value [dataAttributeBinding e_Appointment.countAppointments] 

    event e_MapZoom : Submit : Submit_Update
    event e_MapPan : Submit : Submit_Update 
    event e_DataUpdate : Submit : Submit_Update
    event e_ShowHoverDetails : Submit : Submit_View 
  ]

  // Filters
  component uiCo_TimeFilter "Select Time Range" : Filter : Range [
    dataBinding dec_Appointments
    
    part MinDate "Min Date" : Field : Option [dataAttributeBinding e_Appointment.minDate]
    part MaxDate "Max Date" : Field : Option [dataAttributeBinding e_Appointment.maxDate]
    // Submit Button
    event e_ApplyFilter : Submit : Submit_Update [tag (name "Time Slice" value "Slice Appointment Requests by the selected time range")]
    event e_ResetFilter : Submit : Submit_Update [tag (name "Reset" value "Clear the time filter")] 
  ] 
  // Buttons
  event e_PatientPageButton : Submit : Submit_Back [navigationFlowTo uiCo_PatientOverviewPage]
]
