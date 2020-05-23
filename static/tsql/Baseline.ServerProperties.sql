/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>Server Properties</Title>
	<Description>Server instance properties</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_Property</store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted

select
	getdate() as [TimeStamp],	
	@@servername as [Server],
	serverproperty('BuildClrVersion') as BuildClrVersion,
	serverproperty('Collation') as Collation,
	serverproperty('CollationID') as CollationID,
	serverproperty('ComparisonStyle') as ComparisonStyle,
	serverproperty('ComputerNamePhysicalNetBIOS') as ComputerNamePhysicalNetBIOS,
	serverproperty('Edition') as Edition,
	serverproperty('EditionID') as EditionID,
	serverproperty('EngineEdition') as EngineEdition,
	serverproperty('HadrManagerStatus') as HadrManagerStatus,
	serverproperty('InstanceName') as InstanceName,
	serverproperty('IsAdvancedAnalyticsInstalled') as IsAdvancedAnalyticsInstalled,
	serverproperty('IsClustered') as IsClustered,
	serverproperty('IsFullTextInstalled') as IsFullTextInstalled,
	serverproperty('IsHadrEnabled') as IsHadrEnabled,
	serverproperty('IsIntegratedSecurityOnly') as IsIntegratedSecurityOnly,
	serverproperty('IsLocalDB') as IsLocalDB,
	serverproperty('IsPolybaseInstalled') as IsPolybaseInstalled, 
	serverproperty('IsSingleUser') as IsSingleUser,
	serverproperty('IsXTPSupported') as IsXTPSupported,
	serverproperty('LCID') as LCID,
	serverproperty('LicenseType') as LicenseType,
	serverproperty('MachineName') as MachineName,
	serverproperty('NumLicenses') as NumLicenses,
	serverproperty('ProcessID') as ProcessID,
	serverproperty('ProductBuild') as ProductBuild,
	serverproperty('ProductBuildType') as ProductBuildType,
	serverproperty('ProductMajorVersion') as ProductMajorVersion,
	serverproperty('ProductMinorVersion') as ProductMinorVersion,
	serverproperty('ProductUpdateLevel') as ProductUpdateLevel,
	serverproperty('ProductUpdateReference') as ProductUpdateReference,
	serverproperty('ProductVersion') as ProductVersion,
	serverproperty('ProductLevel') as ProductLevel,
	serverproperty('ResourceLastUpdateDateTime') as ResourceLastUpdateDateTime,
	serverproperty('ResourceVersion') as ResourceVersion,
	serverproperty('ServerName') as ServerName,
	serverproperty('SqlCharSet') as SqlCharSet,
	serverproperty('SqlCharSetName') as SqlCharSetName,
	serverproperty('SqlSortOrder') as SqlSortOrder,
	serverproperty('SqlSortOrderName') as SqlSortOrderName,
	serverproperty('FilestreamShareName') as FilestreamShareName,
	serverproperty('FilestreamConfiguredLevel') as FilestreamConfiguredLevel,
	serverproperty('FilestreamEffectiveLevel') as FilestreamEffectiveLevel
	  