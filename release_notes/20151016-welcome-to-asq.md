SQL Monitor was originally developed as a TechOps tool explicitly meant for monitoring of production databases via automated query execution and error state validation. However, since its release it has become a useful platform for reporting and other non-monitoring tasks by users across the company. The name SQL Monitor has thus grown increasingly ill-suited for describing the work performed. For this reason SQL Monitor has been renamed to **Asq** to better describe it's purpose.

**Asq** (*Automatic SQL Queries*) will be introducing new features in the future that are more tailored to current usage. For now, only the name has changed. If you would like to suggest a feature for Asq, please contact the BEST team. However, please note that despite our opening up this tool for wider use across the company BEST remains a support team first and cannot guarantee to take on any requested features.

This release also contains new features around the scheduling of monitor refreshes. You can now specify when your monitor should refresh using one (or more) of the following method:

*   Interval (every x minutes)
*   Daily (every day at [hh]:[mm])
*   Weekly (every [weekday] at [hh]:[mm])
*   Monthly (every [day of month] at [hh]:[mm])

*Additional Notes:*

*  An Asq with **no** schedules is manual run only.
*  All exsiting Asqs have automatically been converted to an appropriate interval schedule where appropriate. Manually run Asqs will have no schedule.
*  At this time, all times in ASQ are UTC; local time conversion and daylight savings time will require manual adjustment.
*  If you have any questions, you would like to suggest a feature for Asq, or have found a bug, please contact the BEST team.