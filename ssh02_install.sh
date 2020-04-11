#!/bin/sh
#*****************************************************************************************************
# Function : checkDirectory
# Parameters:
#	-directoryFullPath
#	-stringToPrint
# Design:
#       -While printf statement count is not -1,
#               o delete current row and move to previous row
#*****************************************************************************************************
checkDirectory()
{
  printf "  "$2
  if [ -d $1 ]; then
    printf " -> Already exists\n"
  else
    mkdir $1
    printf " -> Created\n"
  fi
}

#*****************************************************************************************************
# Function : checkFile
# Parameters:
#       -fileFullPath
#	-curlFullPath
#       -stringToPrint
# Design:
#       -While printf statement count is not -1,
#               o delete current row and move to previous row
#*****************************************************************************************************
checkFile()
{
  printf "  "$3
  if [ -f $1 ];then
    printf " -> Already exists\n"
  else
    curl -s --retry 3 $2 -o $1
    printf " -> Added\n"
  fi
}

#*****************************************************************************************************
# Function : replaceParameter
# Parameters:
#       -rcFileFullPath
#       -parameterName
#*****************************************************************************************************
replaceParameter()
{
  if [ ! "$(cat $1 | grep $2)" == ""  ];then
    read -p "  Enter value for "$2":" parameterValue
    sed -i 's!'$2'!'$parameterValue'!g' $1
  fi
}

clear

printf "* SSH02-BandwidthUtilizationReport\n  Installer v1.0\n\n"

#*****************************************************************************************************
# STEP0 - Constant declaration
# Design-
#	-Declare color codes
#	-Declare github repo location
#*****************************************************************************************************
frmtInfo='\033[0;33m'
frmtSuc='\033[0;32m'
frmtErr='\033[0;31m'
frmtEnd='\033[0m'
githubRepoLocation='raw.githubusercontent.com/NishadChayanakhawa/SSH02-BandwidthUtilizationReport/master'
linkPrefix='https://'

#*****************************************************************************************************
# STEP1 - Parameter validations
# Design-
#       -Check if token was provided and is not -d. Exit if no token
#*****************************************************************************************************
printf "# Checking git connectivity........."
gitTestFile='raw.githubusercontent.com/NishadChayanakhawa/SSH99-TrainingAndResearch/master/TestToken'
gitToken=$1"@"
gitTestFileFullPath=$linkPrefix$gitToken$gitTestFile
if [ $(curl -s $gitTestFileFullPath) == "Success" ]; then
  printf $frmtSuc"Successful"$frmtEnd"\n"
else
  printf "Failed\n"
  exit
fi

#*****************************************************************************************************
# STEP2 - Working Directory and folder structure
# Design:
#	-Set working directory as PWD
#	-Check folder structure required. Create if not present
#*****************************************************************************************************
WorkingDirectory=$PWD
printf "# Working Directory: ["$WorkingDirectory"]"
printf "  Checking Folder structure\n\n"
checkDirectory $WorkingDirectory"/SSH02-BandwidthUtilizationReport" "+SSH02-BandwidthUtilizationReport"
checkFile $WorkingDirectory"/SSH02-BandwidthUtilizationReport/copyTrafficDatabase.sh" \
          $linkPrefix$gitToken$githubRepoLocation"/copyTrafficDatabase.sh" \
          "|--copyTrafficDatabase.sh"
chmod +x $WorkingDirectory"/SSH02-BandwidthUtilizationReport/copyTrafficDatabase.sh"
checkFile $WorkingDirectory"/SSH02-BandwidthUtilizationReport/BandwidthUtilizationReportRC" \
          $linkPrefix$gitToken$githubRepoLocation"/BandwidthUtilizationReportRC" \
          "|--BandwidthUtilizationReportRC"

#*****************************************************************************************************
# STEP3 - Replace parameters if needed
# Design:
#*****************************************************************************************************
printf "# Setting up parameters\n"
replaceParameter $WorkingDirectory"/SSH02-BandwidthUtilizationReport/BandwidthUtilizationReportRC" "<COPY_TO_LOCATION>"

#*****************************************************************************************************
# STEP6 - Add cronjob
# Design:
#*****************************************************************************************************
printf "# Checking cronjob........."
if [ "$(cat /jffs/scripts/services-start | grep CRONJ_SSH02)" == "" ];then
  echo "#CRONJOB entry for SSH02-BandwidthUtilizationReport. Scheduled to run at 01:00am" >> /jffs/scripts/services-start
  echo "cru a CRONJ_SSH02 \"00 01 * * * "$WorkingDirectory"/SSH02-BandwidthUtilizationReport/copyTrafficDatabase.sh\"" >> /jffs/scripts/services-start
  printf $frmtSuc"Added CRONJ_SSH02"$frmtEnd"\n"
else
  printf $frmtSuc"Not needed."$frmtEnd"\n"
fi
