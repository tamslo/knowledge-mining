DELIMITER //

CREATE PROCEDURE test()
BEGIN
	SELECT @row := @row +1 AS rownum, category
	FROM (SELECT @row := 0) r, categories;
END //

DELIMITER ;