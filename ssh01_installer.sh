#!/bin/sh

#*****************************************************************************************************
# Function : erasePrintf
# Parameters: Printf statement count
# Design:
#       -While printf statement count is not -1,
#               o delete current row and move to previous row
#*****************************************************************************************************
erasePrintf()
{
  iCount=$1
  while [[ $iCount -ne -1 ]]
    do
    printf "\033[A\33[2K"
    iCount=$(($iCount - 1))
  done
}
#*****************************************************************************************************

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
  if [ ! "$(cat $1 | grep $2)" = ""  ];then
    read -p "  Enter value for "$2":" parameterValue
    sed -i 's/'$2'/'$parameterValue'/g' $1
  fi
}

clear
echo "###################################################################################"
echo "#  #####                  ######                   ######                         #"
echo "# #     #  ######  #####  #     #    ##    #    #  #     #    ##    #####    ##   #"
echo "# #        #         #    #     #   #  #   #    #  #     #   #  #     #     #  #  #"
echo "# #  ####  #####     #    ######   #    #  #    #  #     #  #    #    #    #    # #"
echo "# #     #  #         #    #   #    ######  # ## #  #     #  ######    #    ###### #"
echo "# #     #  #         #    #    #   #    #  ##  ##  #     #  #    #    #    #    # #"
echo "#  #####   ######    #    #     #  #    #  #    #  ######   #    #    #    #    # #"
echo "#                                                                                 #"
echo "# Installer v1.0                                                                  #"
echo "###################################################################################"
echo ""

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
githubRepoLocation='raw.githubusercontent.com/NishadChayanakhawa/SSH01-SendRawData/master'
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
if [ $(curl -s $gitTestFileFullPath) = "Success" ]; then
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
checkDirectory $WorkingDirectory"/SSH01-SendRawData" "+SSH01-SendRawData"
checkDirectory $WorkingDirectory"/SSH01-SendRawData/ATTACHMENTS" "|--ATTACHMENTS"
checkFile $WorkingDirectory"/SSH01-SendRawData/sendRawData.sh" \
          $linkPrefix$gitToken$githubRepoLocation"/sendRawData.sh" \
          "|--sendRawData.sh"
chmod +x $WorkingDirectory"/SSH01-SendRawData/sendRawData.sh"
checkFile $WorkingDirectory"/SSH01-SendRawData/msmtprc" \
          $linkPrefix$gitToken$githubRepoLocation"/msmtprc" \
          "|--msmtprc"
checkFile $WorkingDirectory"/SSH01-SendRawData/muttrc" \
          $linkPrefix$gitToken$githubRepoLocation"/muttrc" \
          "|--muttrc"
checkFile $WorkingDirectory"/SSH01-SendRawData/sendRawDataRC" \
          $linkPrefix$gitToken$githubRepoLocation"/sendRawDataRC" \
          "|--sendRawDataRC"
checkFile $WorkingDirectory"/SSH01-SendRawData/TestMail" \
          $linkPrefix$gitToken$githubRepoLocation"/TestMail" \
          "|--TestMail"

#*****************************************************************************************************
# STEP3 - Replace parameters if needed
# Design:
#*****************************************************************************************************
printf "# Setting up parameters\n"
replaceParameter $WorkingDirectory"/SSH01-SendRawData/sendRawDataRC" "<MAIL_FROM>"
replaceParameter $WorkingDirectory"/SSH01-SendRawData/sendRawDataRC" "<MAIL_TO>"
replaceParameter $WorkingDirectory"/SSH01-SendRawData/sendRawDataRC" "<ROUTER_NAME>"
replaceParameter $WorkingDirectory"/SSH01-SendRawData/msmtprc" "<USER_NAME>"
replaceParameter $WorkingDirectory"/SSH01-SendRawData/msmtprc" "<PASSWORD>"
replaceParameter $WorkingDirectory"/SSH01-SendRawData/muttrc" "<ROUTER_NAME>"
replaceParameter $WorkingDirectory"/SSH01-SendRawData/muttrc" "<MAIL_FROM>"
#*****************************************************************************************************
# STEP4 - Check msmtp installation
# Design:
#*****************************************************************************************************
printf "# Check msmtp installation........."
if [ -f /opt/bin/msmtp ]; then
  printf $frmtSuc"Installed"$frmtEnd"\n"
else
  printf $frmtErr"Installation not found. Install msmtp"$frmtEnd"\n"
  exit
fi

#*****************************************************************************************************
# STEP4 - Check muttrc installation
# Design:
#*****************************************************************************************************
printf "# Check muttrc installation........."
if [ -f /opt/bin/mutt ]; then
  printf $frmtSuc"Installed"$frmtEnd"\n"
else
  printf $frmtErr"Installation not found. Install mutt"$frmtEnd"\n"
fi

#*****************************************************************************************************
# STEP5 - msmtprc settings update
# Design:
#*****************************************************************************************************
printf "# Updating msmtprc setting........."
cat $WorkingDirectory"/SSH01-SendRawData/msmtprc" > /opt/etc/msmtprc
echo "TEST MAIL-MSMTP" | msmtp nishad.chayanakhawa@gmail.com
printf $frmtSuc"Updated. Test mail sent to nishad.chayanakhawa@gmail.com"$frmtEnd"\n"

#*****************************************************************************************************
# STEP6 - muttrc settings update
# Design:
#*****************************************************************************************************
printf "# Updating /jffs/scripts/services-start for muttrc........."
if [ "$(cat /jffs/scripts/services-start | grep MuttRCCustomSettings-START)" = "" ];then
  cat $WorkingDirectory"/SSH01-SendRawData/muttrc" >> /jffs/scripts/services-start
  printf $frmtSuc"Updated"$frmtEnd"\n"
else
  printf $frmtSuc"Not needed. Test mail sent"$frmtEnd"\n"
  mutt -s "TEST MAIL-MUTT" -- nishad.chayanakhawa@gmail.com < $WorkingDirectory"/SSH01-SendRawData/TestMail"
fi

#*****************************************************************************************************
# STEP6 - Add cronjob
# Design:
#*****************************************************************************************************
printf "# Checking cronjob........."
if [ "$(cat /jffs/scripts/services-start | grep CRONJ_SSH01)" = "" ];then
  echo "#CRONJOB entry for SSH01-SendRawData. Scheduled to run at 05:00 am" >> /jffs/scripts/services-start
  echo "cru a CRONJ_SSH01 \"00 05 * * * "$WorkingDirectory"/SSH01-SendRawData/sendRawData.sh\"" >> /jffs/scripts/services-start
  printf $frmtSuc"Added CRONJ_SSH01"$frmtEnd"\n"
else
  printf $frmtSuc"Not needed."$frmtEnd"\n"
fi
