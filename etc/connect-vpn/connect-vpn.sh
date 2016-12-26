#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# ==============================================================================
# PAQUETE: connect-vpn
# ARCHIVO: connect-vpn.sh
# DESCRIPCIÓN: Script que permite conectarte a una vpn
# COPYRIGHT:
#  (C) 2016 Victor Pino <victopin0@gmail.com>
# LICENCIA: GPL3
# ==============================================================================
#
# Este programa es software libre. Puede redistribuirlo y/o modificarlo bajo los
# términos de la Licencia Pública General de GNU (versión 3).

PATHL=$(pwd)

x=1
y=0

#
# @name checkroot
# @desc Function that check if the user is root
# @returns {0}
#
function checkroot () {
    
    WHO=$(whoami)

    if [ $WHO != "root" ]; then
        
        zenity --info \
            --text="Necesitas ser SUPER USUARIO para poder conectarte."

        exit 1

    fi
}

#
# @name out
# @desc Function that only print message and Finish execution
# @returns {0}
#
function out()
{

    zenity --info \
            --text="Conexión cancela. Hasta luego"
        
    exit 1

}

#
# @name tailVPN
# @desc Function that show log of the connect in a DIALOG
# @returns {LOG}
#
function tailVPN()
{
    case $? in

        *)

            tail -f $PATHL/vpn.log | zenity --list --title "Conexión con la VPN" --width=500 --height=500 --text "Log de Conexión" --column "VPN" 

            ID=$?

            kill -9 $ID

            out
        
        ;;

    esac

}


#
# @name progressConnect
# @desc Function that show the progress of the connect in a DIALOG
# @returns {progress}
#
function progressConnect()
{

    (

        echo "Iniciando Conexión" ; sleep 1
        echo "50" ; sleep 1
        echo "Ejecutando Conexión" ; sleep 1
        echo "75" ; sleep 1
        echo "Conectando ..." ; sleep 1
        echo "100" ; sleep 1
    
    ) |

        zenity --progress \
        --timeout=6 \
        --title="Conexión VPN" \
        --text="Iniciando Conexión" \
        --percentage=0

}

#
# @name fileOPVN
# @desc Function that set the file .opvn
# @returns {file.opvn}
#
function fileOPVN()
{

    FILE="$(zenity --file-selection --title='Selecciona el archivo .opvn')"
    
    case $? in

            0)
                
                progressConnect
                openvpnc

            ;;
            
            1)

                zenity --question \
                     --title="OpenVPN" \
                     --text="No seleccionaste el archivo. Selecciona el archivo por favor" \
                     && fileOPVN || exit
            ;;

            *)
                out   
            ;;

    esac
}

#
# @name data
# @desc Function that validate the data and return the user and passowrd
# @returns {user, password}
#
function data()
{

    fact=$(zenity --forms \
        --title="Conexión VPN" \
        --text="VPN" \
        --add-entry="Usuario" \
        --add-password="Contraseña" \
        --separator="|")

    case $? in

        0)

            export user=$(echo "$fact" | cut -d "|" -f1)

            if [ -z $user ];

                then

                    zenity --warning \
                        --text="Debe digitar un nombre de usuario"

                    data
            fi

            export password=$(echo "$fact" | cut -d "|" -f2)

            if [ -z $password ];

                then

                    zenity --warning \
                        --text="Debe digitar una Contraseña"

                    data
           
            fi

            if [[ -n $user && -n $password ]];

                then

                y=1
                echo $y
           
            fi
        
            if [ $state = "CANTV" ];
                
                then
                
                openconnection

            elif [ $state = "ME" ]; 
                
                then

                fileOPVN

            fi
            
        ;;

        *)
    
            out

        ;;

    esac


}

#
# @name openconnect
# @desc This function allow the connect with a vpn with the command "openconnect"
# @param {string} user The user entered by the user
# @param {string} password The password entered by the user
# @param {string} url The url to connect the VPN 
# @returns {connect}
#
function openconnection()
{

    connect=$(echo -n $password | openconnect -v -u $user -g mppe_ge --passwd-on-stdin https://webvpn.dch.cantv.com.ve | zenity --list --title "Conexión VPN" --width=500 --height=500 --text "Estatus de Conexón" --column "VPN")
 
}

#
# @name openvpn
# @desc This function allow the connect with a vpn with the command "openvpn"
# @param {string} user The user entered by the user
# @param {string} password The password entered by the user
# @param {string} url The url to connect the VPN 
# @returns {connect}
#
function openvpnc()
{
    #PATH of file selected
    PF=$(echo "${FILE%/*}")

    #Name of file selected
    NF=$(echo "${FILE##*/}")

    echo $password > $PATHL/passwd.txt

    cd $PF

    connect=$(openvpn --config $NF --user $user --askpass $PATHL/passwd.txt | zenity --list --title "Conexion VPN" --column "Log" --width=500 --height=500 --text "Estatus de la Conexion")


}

    checkroot

    while [ $x -gt 0 ]; 

        do

            export state=$(zenity  --list  \
                        --text="Seleccione a donde se quiere conectar" \
                        --radiolist --column="Select" --column="Lugar" TRUE "CANTV" FALSE "ME")

            case $? in

                0)

                    case $state in

                        '')
                            zenity --warning \
                            --text="Debe Selecionar el lugar"
                        ;;

                        "CANTV" | "ME")
                    
                            data
                            x=0
                        ;;

                    esac 

                ;;

                *)
                
                    out
                ;;

            esac

    done
