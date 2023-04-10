CREATE VIEW dbo.vw_User
AS
SELECT    u.UserId
		, u.Name      AS UserName
        , u.Email     AS UserEmail  
        , u.Notes     AS UserNotes  
FROM dbo.User u;
