#!/bin/bash

user_id=`id -u`

if [ $user_id -ne 0 ]; then
    echo "Need to run with sudo privilege"
    exit 1
fi

# Determine OS type 
# Debian based OS (Debian, Ubuntu, Linux Mint) has /etc/debian_version
# Fedora based OS (Fedora, Redhat, Centos, Oracle Linux 7) has /etc/redhat-release
# SUSE based OS (OpenSUSE, SUSE Enterprise) has ID_LIKE=suse in /etc/os-release
# Mariner based OS (CBL-Mariner) has /etc/mariner-release

function print_repositories_and_deps_warning()
{
    echo "Please make sure that required repositories are connected for relevant package installer."
    echo "For issues with dependencies installation (like 'dependency was not found in repository' or 'problem retrieving the repository index file') - you can reach out to distribution owner for futher support."
}

function print_errormessage() 
{
    echo "Can't install dotnet core dependencies."
    print_repositories_and_deps_warning
    echo "You can manually install all required dependencies based on following documentation"
    echo "https://docs.microsoft.com/en-us/dotnet/core/dependencies?pivots=os-linux&tabs=netcore31"
}

function print_rhel6message() 
{
    echo "We did our best effort to install dotnet core dependencies"
    echo "However, there are some dependencies which require manual installation"
    print_repositories_and_deps_warning
    echo "You can install all remaining required dependencies based on the following documentation"
    echo "https://github.com/dotnet/core/blob/master/Documentation/build-and-install-rhel6-prerequisites.md"
}

function print_rhel6errormessage() 
{
    echo "We couldn't install dotnet core dependencies"
    print_repositories_and_deps_warning
    echo "You can manually install all required dependencies based on following documentation"
    echo "https://docs.microsoft.com/en-us/dotnet/core/dependencies?pivots=os-linux&tabs=netcore31"
    echo "In addition, there are some dependencies which require manual installation. Please follow this documentation" 
    echo "https://github.com/dotnet/core/blob/master/Documentation/build-and-install-rhel6-prerequisites.md"
}

if [ -e /etc/os-release ]
then
    echo "--------OS Information--------"
    cat /etc/os-release
    echo "------------------------------"

    if [ -e /etc/debian_version ]
    then
        echo "The current OS is Debian based"
        echo "--------Debian Version--------"
        cat /etc/debian_version
        echo "------------------------------"
        
        # prefer apt over apt-get        
        command -v apt
        if [ $? -eq 0 ]
        then
            apt update && apt install -y liblttng-ust0 libkrb5-3 zlib1g debsums
            if [ $? -ne 0 ]
            then
                echo "'apt' failed with exit code '$?'"
                print_errormessage
                exit 1
            fi

	        # debian 10 uses libssl1.1
            # debian 9 uses libssl1.0.2
            # other debian linux use libssl1.0.0
            apt install -y libssl1.1 || apt install -y libssl1.0.2 || apt install -y libssl1.0.0
            if [ $? -ne 0 ]
            then
                echo "'apt' failed with exit code '$?'"
                print_errormessage
                exit 1
            fi

            # libicu versions: libicu67 -> libicu66 -> libicu63 -> libicu60 -> libicu57 -> libicu55 -> libicu52
            apt install -y libicu67 || apt install -y libicu66 || apt install -y libicu63 || apt install -y libicu60 || apt install -y libicu57 || apt install -y libicu55 || apt install -y libicu52
            if [ $? -ne 0 ]
            then
                echo "'apt' failed with exit code '$?'"
                print_errormessage
                exit 1
            fi
        else
            command -v apt-get
            if [ $? -eq 0 ]
            then
                apt-get update && apt-get install -y liblttng-ust0 libkrb5-3 zlib1g debsums
                if [ $? -ne 0 ]
                then
                    echo "'apt-get' failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi
                
                # debian 10 uses libssl1.1
                # debian 9 uses libssl1.0.2
                # other debian linux use libssl1.0.0
                apt-get install -y libssl1.1 || apt-get install -y libssl1.0.2 || apt-get install -y libssl1.0.0
                if [ $? -ne 0 ]
                then
                    echo "'apt-get' failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi

                # libicu versions: libicu67 -> libicu66 -> libicu63 -> libicu60 -> libicu57 -> libicu55 -> libicu52
                apt-get install -y libicu67 || apt-get install -y libicu66 || apt-get install -y libicu63 || apt-get install -y libicu60 || apt-get install -y libicu57 || apt-get install -y libicu55 || apt-get install -y libicu52
                if [ $? -ne 0 ]
                then
                    echo "'apt-get' failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi
            else
                echo "Can not find 'apt' or 'apt-get'"
                print_errormessage
                exit 1
            fi
        fi
    elif [ -e /etc/redhat-release ]
    then
        echo "The current OS is Fedora based"
        echo "--------Redhat Version--------"
        cat /etc/redhat-release
        echo "------------------------------"

        # use dnf on fedora
        # use yum on centos and redhat
        if [ -e /etc/fedora-release ]
        then
            command -v dnf
            if [ $? -eq 0 ]
            then
                useCompatSsl=0
                grep -i 'fedora release 28' /etc/fedora-release
                if [ $? -eq 0 ]
                then
                   useCompatSsl=1
                else 
                    grep -i 'fedora release 27' /etc/fedora-release
                    if [ $? -eq 0 ]
                    then
                        useCompatSsl=1
                    else
                        grep -i 'fedora release 26' /etc/fedora-release
                        if [ $? -eq 0 ]
                        then
                            useCompatSsl=1
                        fi
                    fi
                fi

                if [ $useCompatSsl -eq 1 ]
                then
                    echo "Use compat-openssl10-devel instead of openssl-devel for Fedora 27/28 (dotnet core requires openssl 1.0.x)"                    
                    dnf install -y compat-openssl10
                    if [ $? -ne 0 ]
                    then
                        echo "'dnf' failed with exit code '$?'"
                        print_errormessage
                        exit 1
                    fi
                else
                    dnf install -y openssl-libs
                    if [ $? -ne 0 ]
                    then
                        echo "'dnf' failed with exit code '$?'"
                        print_errormessage
                        exit 1
                    fi
                fi       

                dnf install -y lttng-ust krb5-libs zlib libicu
                if [ $? -ne 0 ]
                then
                    echo "'dnf' failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi         
            else
                echo "Can not find 'dnf'"
                print_errormessage
                exit 1
            fi
        else
            command -v yum
            if [ $? -eq 0 ]
            then
                yum install -y openssl-libs krb5-libs zlib libicu
                if [ $? -ne 0 ]
                then                    
                    echo "'yum' failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi

                # install lttng-ust separately since it's not part of offical package repository, try installing from local package first, then add repo if it's missing
                if ! yum install -y lttng-ust
                then
                    yum install -y wget ca-certificates && wget -P /etc/yum.repos.d/ https://packages.efficios.com/repo.files/EfficiOS-RHEL7-x86-64.repo && rpmkeys --import https://packages.efficios.com/rhel/repo.key && yum updateinfo -y && yum install -y lttng-ust
                fi
                if [ $? -ne 0 ]
                then                    
                    echo "'lttng-ust' installation failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi
            else
                echo "Can not find 'yum'"
                print_errormessage
                exit 1
            fi
        fi
    else
        # we might on OpenSUSE
        OSTYPE=$(grep ^ID_LIKE /etc/os-release | cut -f2 -d=)
        if [ -z $OSTYPE ]
        then
            OSTYPE=$(grep ^ID /etc/os-release | cut -f2 -d=)
        fi
        echo $OSTYPE

        # is_sles=1 if it is a SLES OS
        [ -n $OSTYPE ] && ([ $OSTYPE == '"sles"' ] || [ $OSTYPE == '"sles_sap"' ]) && is_sles=1

        if  [[ -n $OSTYPE && ( $OSTYPE == '"suse"'  || $is_sles == 1) ]]
        then
            echo "The current OS is SUSE based"
            command -v zypper
            if [ $? -eq 0 ]
            then
                if [[ -n $is_sles ]]
                then
                    zypper -n install lttng-ust libopenssl1_1 krb5 zlib libicu
                else
                    zypper -n install lttng-ust libopenssl1_0_0 krb5 zlib libicu
                fi

                if [ $? -ne 0 ]
                then
                    echo "'zypper' failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi
            else
                echo "Can not find 'zypper'"
                print_errormessage
                exit 1
            fi
        elif [ -e /etc/mariner-release ]
        then
            echo "The current OS is Mariner based"
            echo "--------Mariner Version--------"
            cat /etc/mariner-release
            echo "------------------------------"

            command -v yum
            if [ $? -eq 0 ]
                then
                yum install -y icu
                if [ $? -ne 0 ]
                then                    
                    echo "'yum' failed with exit code '$?'"
                    print_errormessage
                    exit 1
                fi
            else
                echo "Can not find 'yum'"
                print_errormessage
                exit 1
            fi
        else
            echo "Can't detect current OS type based on /etc/os-release."
            print_errormessage
            exit 1
        fi
    fi
elif [ -e /etc/redhat-release ]
# RHEL6 doesn't have an os-release file defined, read redhat-release instead
then
    redhatRelease=$(</etc/redhat-release)
    if [[ $redhatRelease == "CentOS release 6."* || $redhatRelease == "Red Hat Enterprise Linux Server release 6."* ]]
    then
        echo "The current OS is Red Hat Enterprise Linux 6 or Centos 6"

        # Install known dependencies, as a best effort.
        # The remaining dependencies are covered by the GitHub doc that will be shown by `print_rhel6message`
        command -v yum
        if [ $? -eq 0 ]
        then
            yum install -y openssl krb5-libs zlib
            if [ $? -ne 0 ]
            then                    
                echo "'yum' failed with exit code '$?'"
                print_rhel6errormessage
                exit 1
            fi
        else
            echo "Can not find 'yum'"
            print_rhel6errormessage
            exit 1
        fi

        print_rhel6message
        exit 1
    else
        echo "Unknown RHEL OS version"
        print_errormessage
        exit 1
    fi
else
    echo "Unknown OS version"
    print_errormessage
    exit 1
fi

echo "-----------------------------"
echo " Finish Install Dependencies"
echo "-----------------------------"
