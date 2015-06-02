#!/bin/bash

email_deliverability_domain="email_deliverability"
email_deliverability_domain_wd="$HOME/repo/${email_deliverability_domain}"

psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -f $email_deliverability_domain_wd/sql/fn_emaildeliveredpct.sql dev
psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -f $email_deliverability_domain_wd/sql/fn_emailopenedpct.sql dev
psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -f $email_deliverability_domain_wd/sql/fn_emailclickedpct.sql dev
psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -f $email_deliverability_domain_wd/sql/fn_emailunsubscribedpct.sql dev
psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -f $email_deliverability_domain_wd/sql/fn_emailstoredpct.sql dev
psql -h 10.223.176.157 -p 5432 -U jteruya -A -F"," --no-align --pset footer -f $email_deliverability_domain_wd/sql/fn_emailcomplainedpct.sql dev
