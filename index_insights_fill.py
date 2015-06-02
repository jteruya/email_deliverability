#!/usr/bin/python

import sys
import os
import csv
import string
import re

# --------------------------------------------------------------------------------
# Index Insights Fill Script
# - Identify the changes that are worth identifying for notes to the reports. 
#
# Domain: CORE
#
# Input:
# 1. HTML Template File
# 2. Intended HTML Output File
# 3. Base Report CSV Data
# --------------------------------------------------------------------------------

html_template_file=sys.argv[1]
output_html_file=sys.argv[2]
csv_file=sys.argv[3]

percent_delivered_insight=''
percent_opened_insight=''
percent_clicked_insight=''

with open(output_html_file, 'w') as html_output:

	with open(html_template_file, 'r') as html_template:

		with open(csv_file, 'r') as csv_file:

			reader = csv.reader(csv_file)

			# --------------------------------------------
			# Identify any insights from the report data.
			# --------------------------------------------
			# Read the CSV file for any insights in the data.
			for row in reader:

				metric = row[0]

				# Check on the Event Load Time metrics and provide feedback on the comparison
				if (metric == 'Percent of Accepted Emails Delivered' or metric == 'Percent of Delivered Emails Opened' or metric == 'Percent of Delivered Emails Clicked'):
					metric_30_days_back = float(row[1])
					metric_25_days_back = float(row[2])
					metric_20_days_back = float(row[3])
					metric_15_days_back = float(row[4])
					metric_10_days_back  = float(row[5])
                                        metric_5_days_back = float(row[6])
                                        metric_0_days_back = float(row[7])

					diff_percent_delivered = metric_0_days_back - metric_30_days_back
                                        diff_percent_opened = metric_0_days_back - metric_30_days_back
 					diff_percent_clicked = metric_0_days_back - metric_30_days_back

					# STANDARD INSIGHT
					if (metric == 'Percent of Accepted Emails Delivered'):
						percent_delivered_insight = percent_delivered_insight + "<h3>Current Percent Delivered: " + str(metric_0_days_back) + "%.</h3>"
						percent_delivered_insight = percent_delivered_insight + "<ul style=\"list-style-type:square; margin-left: 10px; padding-left: 20px\">"
				        if (metric == 'Percent of Delivered Emails Opened'):
						percent_opened_insight = percent_opened_insight + "<h3>Current Percent Opened: " + str(metric_0_days_back) + "%.</h3>"
						percent_opened_insight = percent_opened_insight + "<ul style=\"list-style-type:square; margin-left: 10px; padding-left: 20px\">"

                                        if (metric == 'Percent of Delivered Emails Clicked'):
                                                percent_clicked_insight = percent_clicked_insight + "<h3>Current Percent Clicked: " + str(metric_0_days_back) + "%.</h3>"
                                                percent_clicked_insight = percent_clicked_insight + "<ul style=\"list-style-type:square; margin-left: 10px; padding-left: 20px\">"

					# GOOD NEWS
					if (metric_30_days_back < metric_0_days_back and metric == 'Percent of Accepted Emails Delivered'):
						percent_delivered_insight = percent_delivered_insight + "<li>Percent of accepted emails delivered has <b><font color=\"blue\">increased</font></b> since 30 days ago from " + str(metric_30_days_back) + " to " + str(metric_0_days_back) + ". <font color=\"green\">(<b>+" + str(diff_percent_delivered) + "%</b>)</font></li>"
					if (metric_30_days_back < metric_0_days_back and metric == 'Percent of Delivered Emails Opened'):
   						percent_opened_insight = percent_opened_insight + "<li>Percent of delivered emails opened has <b><font color=\"blue\">increased</font></b> since 30 days ago from " + str(metric_30_days_back) + " to " + str(metric_0_days_back) + ". <font color=\"green\">(<b>+" + str(diff_percent_opened) + "%</b>)</font></li>"
                                        if (metric_30_days_back < metric_0_days_back and metric == 'Percent of Delivered Emails Clicked'):
                                                percent_clicked_insight = percent_clicked_insight + "<li>Percent of delivered emails clicked has <b><font color=\"blue\">increased</font></b> since 30 days ago from " + str(metric_30_days_back) + " to " + str(metric_0_days_back) + ". <font color=\"green\">(<b>+" + str(diff_percent_clicked) + "%</b>)</font></li>"

					# BAD NEWS
					if (metric_30_days_back > metric_0_days_back and metric == 'Percent of Accepted Emails Delivered'):
						percent_delivered_insight = percent_delivered_insight + "<li>Percent of accepted emails delivered has <b><font color=\"red\">decreased</font></b> since 30 days ago from " + str(metric_30_days_back) + " to " + str(metric_0_days_back) + ". <font color=\"red\">(<b>" + str(diff_percent_delivered) + "%</b>)</font></li>"
 					if (metric_30_days_back > metric_0_days_back and metric == 'Percent of Delivered Emails Opened'): 
						percent_opened_insight = percent_opened_insight + "<li>Percent of delivered emails opened has <b><font color=\"red\">decreased</font></b> since 30 days ago from " + str(metric_30_days_back) + " to " + str(metric_0_days_back) + ". <font color=\"red\">(<b>" + str(diff_percent_opened) + "%</b>)</font></li>"
                                        if (metric_30_days_back > metric_0_days_back and metric == 'Percent of Delivered Emails Clicked'):
                                                percent_clicked_insight = percent_clicked_insight + "<li>Percent of delivered emails clicked has <b><font color=\"red\">decreased</font></b> since 30 days ago from " + str(metric_30_days_back) + " to " + str(metric_0_days_back) + ". <font color=\"red\">(<b>" + str(diff_percent_clicked) + "%</b>)</font></li>"
			
         		# Cap off the lists.
			percent_delivered_insight = percent_delivered_insight + "</ul>"
                        percent_opened_insight = percent_opened_insight + "</ul>"
                        percent_clicked_insight = percent_clicked_insight + "</ul>"

			# ------------------------------------------------
			# Perform the HTML Replacement from the Template.
			# ------------------------------------------------
			# Read the HTML template record-by-record and replace the insights as needed.
			for row in html_template:
		
				if (row.strip() == '<!--PERCENT_DELIVERED_INSIGHTS-->'):
					html_output.write(percent_delivered_insight)
                                if (row.strip() == '<!--PERCENT_OPENED_INSIGHTS-->'):
					html_output.write(percent_opened_insight)
                                if (row.strip() == '<!--PERCENT_CLICKED_INSIGHTS-->'):
                                        html_output.write(percent_clicked_insight)
				else:
					html_output.write(row)

		
