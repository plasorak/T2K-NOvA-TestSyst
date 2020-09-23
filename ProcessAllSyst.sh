#!/bin/bash

function usage {
    echo "Execute as such ./ProcessAllSysts.sh syst.list Detector NEUT_file.root GENIE_file.root"
    echo "Where syst.list is a list of systematics with of the form:"
    echo "NEUT t2k_parameter NCasc_FrInelLow_pi"
    echo "And Detector is either \"ND280\" or \"NOVAND\""
}

if [ "$#" -ne 4 ]; then
    usage
fi

CURDIR=$(pwd)
syst_list_file=$1
DET=$2
NEUT_FILE=$3
GENIE_FILE=$4
# Assumes ND280 and check for nova
ACCMAPFILE=${ND280ACCEPT_FILE}
ACCMAPPTHETA=${ND280ACCEPT_HIST_PTHETA}
ACCMAPQ0Q3=${ND280ACCEPT_HIST_Q0Q3}
ACCMAPENUY=${ND280ACCEPT_HIST_ENUY}

if [ "${DET}" != "ND280" ] && [ "${DET}" != "NOVAND" ]; then
    echo "ERROR: Invalid detector ${DET} (should be either ND280 or NOVAND)"
    exit
elif [ "${DET}" == "NOVAND" ]; then
    ACCMAPFILE=${NOVANDACCEPT_FILE}
    ACCMAPPTHETA=${NOVANDACCEPT_HIST_PTHETA}
    ACCMAPQ0Q3=${NOVANDACCEPT_HIST_Q0Q3}
    ACCMAPENUY=${NOVANDACCEPT_HIST_ENUY}
fi


while IFS= read -r line
do
    cd $CURDIR
    words=($line)
    # Gets rid of empty lines and comment starting with "#"
    if [ "${#words[@]}" != "0" ] && [ "$(echo ${words[0]}|head -c 1)" != "#" ]; then
        if [ "${#words[@]}" != "3" ];then
            echo "${line} is malformed, ignoring"
            continue
        fi
        
        echo "Processing systematic ${line}"

        GEN=${words[0]}
        TYPE=${words[1]}
        SYST=${words[2]}
        INPUTFILE=../${NEUT_FILE}
        if [ "${GEN}" != "NEUT" ] && [ "${GEN}" != "GENIE" ]; then
            echo "ERROR: Invalid generator ${GEN} in line ${line} (should be either NEUT or GENIE), continue"
            continue
        elif [ "${GEN}" == "GENIE" ]; then
            INPUTFILE=../${GENIE_FILE}
        fi
        
        mkdir $SYST
        cd $SYST
        cardp=${DET}_${GEN}_${SYST}_varup.card
        card=${DET}_${GEN}_${SYST}_var.card
        cardn=${DET}_${GEN}_${SYST}_vardown.card
        
        echo "
<nuisance>
<parameter name=\"${SYST}\" nominal=\"0.5\" type=\"${TYPE}\" state=\"ABS\"/>
<sample
 name=\"T2KNOvAFlatTree\"
 input=\"${GEN}:${INPUTFILE}\"
 acc_map_file=\"${ACCMAPFILE}\"
 acc_map_hist_q0q3=\"${ACCMAPQ0Q3}\"
 acc_map_hist_ptheta=\"${ACCMAPPTHETA}\"
 acc_map_hist_enuy=\"${ACCMAPENUY}\"
/>
</nuisance>">${cardp}
        echo "
<nuisance>
<parameter name=\"${SYST}\" nominal=\"1.0\" type=\"${TYPE}\" state=\"ABS\"/>
<sample
 name=\"T2KNOvAFlatTree\"
 input=\"${GEN}:${INPUTFILE}\"
 acc_map_file=\"${ACCMAPFILE}\"
 acc_map_hist_q0q3=\"${ACCMAPQ0Q3}\"
 acc_map_hist_ptheta=\"${ACCMAPPTHETA}\"
 acc_map_hist_enuy=\"${ACCMAPENUY}\"
/>
</nuisance>">${card}
        
        echo "
<nuisance>
<parameter name=\"${SYST}\" nominal=\"1.5\" type=\"${TYPE}\" state=\"ABS\"/>
<sample
 name=\"T2KNOvAFlatTree\"
 input=\"${GEN}:${INPUTFILE}\"
 acc_map_file=\"${ACCMAPFILE}\"
 acc_map_hist_q0q3=\"${ACCMAPQ0Q3}\"
 acc_map_hist_ptheta=\"${ACCMAPPTHETA}\"
 acc_map_hist_enuy=\"${ACCMAPENUY}\"
/>
</nuisance>">${cardn}
        nuiscomp -c ${card} -o ${card}.root
        nuiscomp -c ${cardp} -o ${cardp}.root
        nuiscomp -c ${cardn} -o ${cardn}.root
    fi
done <"$syst_list_file"
