**New features:**

* Queries containing critical “write” keywords such as INSERT, UPDATE, or DELETE will now display a warning message on screen but will not prevent you from saving. Please note that none of the database connections used by Asq allow write operations but there are legitimate times where you might need to query for a value named "insert".