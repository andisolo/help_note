
#My Shell Tools.



_toolsres='toolsTemp.txt'

#toolsShow $@
function toolsShow(){
    toolsLineLong
    echo ">>date: "`date "+%Y-%m-%d %H:%M:%S" `
    echo ">>shell: "${0}
    echo ">>params: "$*     
    toolsLineShort  
}

#toolsShowMethod $method ${params[*]}
function toolsShowMethod(){ 
    #toolsLineShort  
    echo ">>method: "${1}
    echo ">>params: "${2}     
    toolsLineShort  
}
 
#toolsMakefile filename.txt
function toolsMakefile(){
    filename=$1
    if [ "$filename" = "" ]
    then
        echo 'toolsMakefile create a file must with a filename '
        exit
    else
        if [ ! -f "$filename" ]    # 这里的-f参数判断$myFile是否存在
        then
            touch "$filename"
        fi
    fi
}


#Get params 
#toolsGet $1 <default value>
function toolsGet(){
    res=$1
    default=$2
    if [ "$res" = "" ]
    then
        res=$2
        if [ "$res" = "" ]
        then
            res=''
        fi
    fi
    echo "$res" > $_toolsres    
    return 0
}
#toolsMakestr '--' '10'
function toolsMakestr(){
    res=''
    str=$1
    count=$2 
    if [ -z "$count" ]
    then
        echo 'toolsMakestr eg: toolsMakestr "" "10" '
        res=''
    else
        for ((i=1; i<=$count; i++))
        do
            res=$res''$str
        done
    fi  
    
    echo $res > $_toolsres
    return 0
}
#toolsMakestr 'q' 3 

#Show the split line such as '-----------'
#toolsLine <10>
function toolsLine(){
    split='-'
    str=''
    len=$1
    if [ "$len" = "" ]
    then
        len=16
        #echo "len is not set!"
#    else
#        echo
#        #echo "len is set !"
    fi
    
    for ((i=0; i<$len; i++))
    do
        str=$str""$split
    done

    echo $str
}
 
function toolsLineLong(){
    toolsLine 32
}

function toolsLineShort(){
    toolsLine 8
}











