#!/bin/bash

# ====================================================================================================== ========== -
#
# email_deliverabilitys_core_wrapper.sh 
# ----------------------
# - Wrapper for all scripts that need to be run for the Core Success Dashboard. 
# http://10.223.176.60/product/dashboards/core/
#
# 0. Set the Generic Fields for this script. 
# 1. ETL - Transformation SQL for setting up the static datasets that will be pulled for reports. 
# 2. Email - Runs the Email tool that runs specific SQL to assemble an email that is sent per period. 
# 3. Report - (a) Run the Report SQL, (b) move and transpose the CSVs, (c) and split per report. 
# 4. HTML - Generate the HTML for the Dashboard with any custom insights. 
# 5. Productionalize - Copy the Dashboard elements for use with the Production Web Server. 
#
# ====================================================================================================== ========== -

# Base fields
email_deliverability_domain="email_deliverability"
email_deliverability_domain_formal="email_deliverability_metrics"
email_deliverability_domain_wd="$HOME/repo/${email_deliverability_domain}"

# Report fields
email_deliverability_domain_base_report="${email_deliverability_domain_formal}_report"

# Generic Tools/Scripts
run_sql="python $HOME/repo/tools/get_csv.py"
transpose="python $HOME/repo/tools/transpose.py"
index_insights_fill="python $email_deliverability_domain_wd/index_insights_fill.py"
email_reports_wd="$HOME/repo/email_reports"

# Module settings
email_day=$1 # Set the day that the email will be sent.

# Day of Week
DAYOFWEEK=$(date +"%u")

# ====================================================================================================== ========== 0

echo "================================================================================================="
echo `date` 
echo "Starting script ${email_deliverability_domain}_wrapper.sh..."

# ====================================================================================================== ========== 1
echo "-------------------------------------------------------------------------------------------------"
echo "TRANSFORMATION ($email_deliverability_domain_formal) : " `date` 
echo "-------------------------------------------------------------------------------------------------"
# Perform the SQL read/insert. (do not generate a CSV, that's what the "sql" passed to the script is for)

echo "Running ${email_deliverability_domain}/sql/${email_deliverability_domain}.sql."
psql -h 10.223.176.157 -p 5432 -U jteruya -f $email_deliverability_domain_wd/sql/$email_deliverability_domain.sql dev  

# ====================================================================================================== ========== 2
echo "-------------------------------------------------------------------------------------------------"
echo "QUERY EMAILER ($email_deliverability_domain_formal) : " `date` 
echo "-------------------------------------------------------------------------------------------------"
# 0. Check if the wrapper is set to email on a specific day.
# 1. Run the KPI SQL to perform the load and drop the values from the table into a CSV for emails.
# 2. Transpose the query result set. 
# 3. Send the structured email with any notes about large boosts/drops
if [[ ! -z "$email_day" ]]; then
	if [[ "$email_day" == "Monday" && "$DAYOFWEEK" == "1" ]] || [[ "$email_day" == "Tuesday" && "$DAYOFWEEK" == "2" ]] || [[ "$email_day" == "Wednesday" && "$DAYOFWEEK" == "3" ]] || [[ "$email_day" == "Thursday" && "$DAYOFWEEK" == "4" ]] || [[ "$email_day" == "Friday" && "$DAYOFWEEK" == "5" ]] || [[ "$email_day" == "Saturday" && "$DAYOFWEEK" == "6" ]] || [[ "$email_day" == "Sunday" && "$DAYOFWEEK" == "7" ]] || [[ "$email_day" == "Daily" ]]; then
		echo "Sending email today. (Day of the Week: ${DAYOFWEEK})"
		$email_reports_wd/./query_emailer.sh $email_deliverability_domain_formal custom
	fi
else
	echo "No email is set to be sent."
fi

# ====================================================================================================== ========== 3a
echo "-------------------------------------------------------------------------------------------------"
echo "REPORTS - Run the SQL Reports ($email_deliverability_domain_formal) : " `date` 
echo "-------------------------------------------------------------------------------------------------"
psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -f $email_deliverability_domain_wd/sql/metricdate.sql dev > metricdate.csv 
psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -c 'select * from jt.email_deliverability_metrics;' dev > email_deliverability_metrics_report.csv

# ====================================================================================================== ========== 3b
echo "-------------------------------------------------------------------------------------------------"
echo "REPORTS - Move and Transpose the Report Datasets ($email_deliverability_domain_formal) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

# Move the SQL Result Set CSV
mv $email_deliverability_domain_wd/email_deliverability_metrics_report.csv $email_deliverability_domain_wd/csv/email_deliverability_metrics_report.csv 
mv $email_deliverability_domain_wd/metricdate.csv $email_deliverability_domain_wd/csv/metricdate.csv 

# Transpose the Result Set CSV
$transpose $email_deliverability_domain_wd/csv/metricdate.csv

# Combine Files for Output
cat $email_deliverability_domain_wd/csv/metricdate_transposed.csv > $email_deliverability_domain_wd/csv/email_deliverability_output.csv
sed 1d $email_deliverability_domain_wd/csv/email_deliverability_metrics_report.csv >> $email_deliverability_domain_wd/csv/email_deliverability_output.csv

# ====================================================================================================== ========== 3c
echo "-------------------------------------------------------------------------------------------------"
echo "REPORTS - Split the Datasets for the Reports ($email_deliverability_domain_formal) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

# Email Types Array
emailtype=(welcomeemail dailydigestemail)

# State Array
statetype=(delivered opened clicked unsubscribed stored complained)

# Base Report
for e in ${emailtype[@]}; do
    for s in ${statetype[@]}; do
        head -1 $email_deliverability_domain_wd/csv/email_deliverability_output.csv > ${email_deliverability_domain_wd}/csv/${e}${s}.csv
        cat $email_deliverability_domain_wd/csv/email_deliverability_output.csv | grep "${s}:" | grep "${e}:" | awk -F":" '{print $3}' >> ${email_deliverability_domain_wd}/csv/"${e}${s}".csv    
    done
done

# ====================================================================================================== ========== 4 

echo "-------------------------------------------------------------------------------------------------"
echo "DASHBOARD - Assemble the HTML ($email_deliverability_domain_formal) : " `date` 
echo "-------------------------------------------------------------------------------------------------"
# CUSTOM: Called with a custom input for the App Count.

# Performing Insight insertion to dashboard HTML
#$index_insights_fill $email_deliverability_domain_wd/index_template.html $email_deliverability_domain_wd/index.html $email_deliverability_domain_wd/csv/email_deliverability_output.csv $email_deliverability_domain_wd/csv/AppCount_transposed.csv 

# ====================================================================================================== ========== 5 
echo "-------------------------------------------------------------------------------------------------"
echo "PRODUCTIONALIZE - Copy Dashboard files for Production ($email_deliverability_domain_formal) : " `date` 
echo "-------------------------------------------------------------------------------------------------"

#sudo cp -rf $email_deliverability_domain_wd/index.html /var/www/html/product/dashboards/core/index.html
#sudo cp -rf $email_deliverability_domain_wd/js/* /var/www/html/product/dashboards/core/js
#sudo cp -rf $email_deliverability_domain_wd/image/* /var/www/html/product/dashboards/core/image
#sudo cp -rf $email_deliverability_domain_wd/csv/* /var/www/html/product/dashboards/core/csv

# ====================================================================================================== ========== -
