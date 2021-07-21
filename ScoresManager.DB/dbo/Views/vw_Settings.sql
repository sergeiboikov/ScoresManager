CREATE VIEW [dbo].[vw_Settings]
AS
SELECT	 s.[SettingsId]
		, s.[SettingName]
		, s.[SettingValue]
		, u.[UserId]
        , u.[Email] AS [UserEmail]
FROM [dbo].[Settings] s
INNER JOIN [dbo].[User] u ON u.UserId = s.UserId