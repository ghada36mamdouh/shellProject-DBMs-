 #! /usr/bin/ksh
#Welcome to GHADA project 
clear 
# echo "welcome to .... My DBs world ...."
printf "\e[43m\t\t\t\t welcome to .... My DBs world ....\e[49m\n"
echo -e "\t\t\t\t__________________________________\n"  
  function read_info {
      echo -n " please enter your username..   "
      read  username
     # echo "please enter your password.."
     # read pass
      return $username $pass 2>errorfile
   }

typeset -i attempt 
attempt=0

typeset -i validUser 
validUser=0
  
  function check_validation { 
      read_info
      #--------------username --------------
      users=`cut -d: -f1 login`
      for user in $users 
      do
	  if [[ $user = $username ]]
	  then  
       	        printf "\n\e[42m\t\t\t welcome $username\e[49m\n"
# 		echo -e " welcome $username \n " 
		let validUser=1 ; 
		DBmenu
	  fi	  
      done
      #--------------userpass --------------
      
      #--------------attempts --------------
      if [[ validUser -eq 0 ]]
      then
              let attempt=$attempt+1 ;
              echo -e "\t wrong username , plz try again , attempt $attempt (you have only three attempts)" ;
	      if [[ attempt -lt 3 ]] 
		then
		    check_validation 
	      else 
	            echo "-----------------------------"  
		    echo "  Sorry u made 3 attempts";
		    echo "-----------------------------"  
	      fi
      fi
  }
# ---------------- lets start our work--------------------------------------------------- 
# ---------------- ---menu--- --------------- 
  function DBmenu {
      echo "-----------------------------" 
      printf "\e[41m   MAIN MENU \e[49m\n"
#       echo -e " MAIN MENU"
      echo "----------"  
      select choice in 'Show DataBases' 'Create new Data Base' 'Drop DataBase' 'exit' 
      do 
        case $choice in 
	  'Show DataBases') showDBs ; break;;
	  'Create new Data Base') newDB ; break;;
          'Drop DataBase') DropDB ; break;;
	  'exit' ) exit ; break;;
	  *) echo $REPLY is not valid you have only four choices ; DBmenu; break ;;
        esac
      done
  }
# -------------------show DataBases -------------
  function showDBs {
      printf "\n\e[44m DataBases Names\e[49m \n"
#       echo -e "\n DataBases Name "
      echo -e " ______________ \n "
      ls DBs | cat  
      echo -e "\n Do you want to select data base ??"
      select choice in 'yes' 'No' 
      do 
        case $choice in 
	  'yes')  echo -n " please,choise DB (enter its name) .. "
		  read dbname
		    if test `ls DBs | grep ^$dbname$ `
		    then  
			selectDB $dbname     
		    else
			echo -e "\t this DataBase not exist"
			showDBs
		    fi 
	         break;;
	  'No') clear ;DBmenu ; break;;
	  *) echo -e "\t $REPLY is not valid" ; DBmenu ;break ;;
        esac
      done  
}
# ------------------create new data base---  
  function newDB {
      echo -n " please enter newDB name .."
      read dbname
      if test `ls DBs | grep ^$dbname `
      then  
           echo -e "\t this DataBase is exist ,choose another name " 
       select choice in 'continue any way' 'cancel'
                do 
		    case $choice in 
			'continue any way') selectDB $dbname ; break  ;;
		        'cancel') clear; DBmenu; break ;;
			*) echo -e "\t $REPLY is not valid."; break ;;
		    esac
	       done  
      else
	   mkdir DBs/$dbname 
           ls DBs > DBsMetaData 
           selectDB $dbname
      fi 
      
  }
# ------------------Delete data base-------
  function DropDB {
	echo -n " please enter newDB name you want to Drop .. "
	read ddbname
	if test `ls DBs | grep ^$ddbname`
	then  
	    echo "Are you sure you want to delete $ddbname ? "    
	    select choice in 'yes' 'cancel'
		  do 
		      case $choice in 
			  'yes') rm -r DBs/$ddbname 
	                                      ls DBs > DBsMetaData  
			                      break  ;;
			  'cancel')clear; DBmenu; break ;;
			  *) echo -e "\t $REPLY is not valid."; break ;;
		      esac
		 done
	     ls DBs | cat -n
	else
	    echo -e "\t this DataBase is not exist "    
	fi
	clear
        DBmenu
    }
# -------------------show oneDataBase -------------
  function selectDB  {       
        clear
	echo "----------------------------------------------------------"
        printf "\n\e[44m Data Base name\e[49m : $dbname \n"
# 	echo Data Base name : $1 
	echo "---------"
	printf "\n\e[45m Tables \e[49m : \n"
# 	echo Tables :
	echo `ls DBs/$dbname | grep -v ^meta`
	echo "---------"
	echo " you want to "
	select choice in 'Select Table' 'Create new table' 'drop table' 'alter table' 'main Menu' 
	  do 
	    case $choice in 
	      'Select Table')   echo -n " table name you want to select .. "
				read tname 
				if test `ls DBs/$dbname | grep ^$tname$ `
				then
				   selectT $tname 
				else
				    echo "this table not exist"	
				    selectDB $dbname
				fi     
	                          break ;;
	      'Create new table') creatTable ; break ;;
	      'drop table') delTable ; break ;;
	      'alter table') echo "table name you want to alter .."
                            read atname 
	                    alterTable ; break;; 
	      'main Menu') clear; DBmenu ; break ;;
	      *) echo $REPLY is not valid.
		 break ;;
	    esac
	  done   
  }
# -------------------creatTable -------------
  function creatTable { 
      echo -n " please enter newTable name .. "
      read tname 
      if test -f DBs/$dbname/$tname
      then
	    echo -e "\t this is table is exist choose anthor name "
	    select choice in 'continue' 'cancel'
	       do 
		    case $choice in 
			'continue')  creatTable ; break ;;
		        'cancel') selectDB $dbname ; break ;;
			*) echo -e "\t $REPLY is not valid."; break ;;
		    esac
	       done  
      else
	    touch DBs/$dbname/$tname
	    #-------create cols with data types -------
	    echo "--------"
	    echo -n " enter number of columns "; read n ;
	    let n=$n+1 ; i=1
	    while [ $i -lt $n ]
	    do
	       echo "--------"
	       echo -n " col$i name  " ;read colName ;
	       echo "--------"
	       echo " select col$i type "
	       echo "--------"
	       select choice in 'int' 'string'  
	       do 
		    case $choice in 
			'int') coltype="int"; break ;;
			'string') coltype="string"; break ;;
			*) echo -n "\t $REPLY is not valid. "; break ;;
		    esac
	       done  
	       let i=$i+1 
	       #----------- put data into file---------------       
	       echo "$colName:$coltype" >> DBs/$dbname/meta${tname} 
	    done
	    printf "\n\e[44m Now the cols are \e[49m : \n"
# 	    echo " now the cols are : "
	    cut -d: -f1 DBs/$dbname/meta${tname} 
	    function pkey {
		  echo -n "choice table primary key ...."
		  read pk
		  if test `cut -d: -f1 DBs/$dbname/meta${tname} | grep ^$pk$` 
		  then
                        lval=`sed -n "/^$pk/p" DBs/$dbname/meta${tname}`":primary key"
#                         echo $lval
			sed -i "/^$pk/ c\ \n$lval" DBs/$dbname/meta${tname}
  			sed -i '/^ $/d' DBs/$dbname/meta${tname}
		  else
			echo -e "\t this col not exist"
			pkey
		  fi     
	    }
	    pkey 
      fi  
      #////////
      selectT $tname
  }
# -------------------delTable -------------
  function delTable { 
      echo -n " table name you want to delete ..  "
      read dtname 
      if test `ls DBs/$dbname | grep ^$dtname `
      then
           rm DBs/$dbname/$dtname 
           rm DBs/$dbname/meta${dtname} 
	   echo "\t $dtname is deleted "
      else
	   echo "\t this table not exist "	   
      fi     
      selectDB $dbname
      
  }   
# -------------------alterTable -----------
  function alterTable {     
      if test `ls DBs/$dbname | grep ^$atname `
      then 
           echo "----------"
           echo  " you want to .. "
           select choice in 'add column' 'delete column' 'cancel'
	       do 
		    case $choice in 
			'add column') addCol
			       break
			  ;;
			'delete column') deleteCol
			       break
			  ;;
		        'cancel') selectDB $dbname
			       break
			  ;;
			*) echo -e "\t $REPLY is not valid."
			       break
			  ;;
		    esac
	       done  
      else
	   echo -e "\t this table not exist "
	   alterTable	        
      fi         
  }
# -------------------delcol --------------- 
  function deleteCol {
       printf "\n\e[44m columns \e[49m : \n"
#        echo " columns := "
       cut -d: -f1 DBs/$dbname/meta${atname}
       echo -n " column you want to delete??"
       read delcol
       echo "----------"
       if test `grep $delcol DBs/$dbname/meta${atname}`
       then
            colnum=`sed -n "/^$delcol/=" DBs/$dbname/meta${atname}`
            feilds=`cut -d: -f$colnum --complement DBs/$dbname/$atname`
            echo $feilds > DBs/$dbname/$atname
            sed -i "/^$delcol/d" DBs/$dbname/meta${atname}
       else
           echo -e "\t this column not exist"
           echo "----------"
           select choice in 'continue' 'cancel'
	       do 
		    case $choice in 
			'continue') deleteCol ; break ;;
		        'cancel')  alterTable ; break ;;
			*) echo -e "\t $REPLY is not valid."; break ;;
		    esac
	       done  
       fi
       alterTable
  }
# -------------------addcol --------------- 
  function addCol { 
       printf "\n\e[44m columns \e[49m : \n"
#        echo "columns := "
#        cat DBs/$dbname/meta${atname}
       cut -d: -f1 DBs/$dbname/meta${atname}
       echo -n " column name you want to add?? "
       read addcol
       echo "----------"
       if test `grep $addcol DBs/$dbname/meta${atname} `
       then
           echo -e "\t this column is exist "
           echo "----------" 
            
       else
           echo " select col type "
	       echo "--------"
	       select choice in 'int' 'string'  
	       do 
		    case $choice in 
			'int') coltype="int"; break ;;
			'string') coltype="string"; break ;;
			*) echo -e "\t $REPLY is not valid." ; break ;;
		    esac
	       done  
           echo "$addcol:$coltype" >> DBs/$dbname/meta${atname}                   
       fi
       alterTable
  }
# -------------------selectT --------------
  function selectT {
        clear
        echo "----------------------------------------------------------"
        tname=$1 
        printf "\e[41m Data Base $dbname : \e[46m table $1: \e[49m \n"
# # 	echo Data Base $dbname : table $1
	echo "---------"
        printf "\n\e[42m columns \e[49m : \n"
# 	echo Table Columns :
	echo `cut -d: -f1 DBs/$dbname/meta$1`
	echo "---------"
	echo "you want to "
	select choice in 'select row' 'insert row' 'update row' 'delete row' 'cancel' 
	  do 
	    case $choice in
	      'select row') selectRow 
	                    break ;;
	                    
	      'insert row') insertRow $1 ; break ;;
             
              'update row') updateRow 
	                    break ;;	
	                    
	      'delete row') delRow ; break;; 
	      'cancel')  selectDB ; break ;;
	      *) echo -e "\t $REPLY is not valid."
		 break ;;
	    esac
	  done     
  }
# -----------------insert row ------------- 
  
  function insertRow {
    clear 
    printf "\e[43m\t\t\t\t Insert Row \e[49m\n\n\n"
    numofcol=`awk -F: 'END { print NR }' DBs/$dbname/meta$1`
    pkcol=`sed -n '/primary key/=' DBs/$dbname/meta$1`
    i=1 ; row="" 
    printf "\n\e[41m enter row data  \e[49m : \n"
#     echo enter row data 
    echo "--------"
    while [ $i -le $numofcol ]
    do     
       echo -n "enter "
       sed -n "$i p" DBs/$dbname/meta$1 | cut -d: -f1 
       type=`sed -n "$i p" DBs/$dbname/meta$1 | cut -d: -f2`
       if [[ $i -eq $pkcol ]]
       then 
            pkflag="t"          
       else
            pkflag="f"  
       fi
       
       checkType $1
       
       if [ $i -lt $numofcol ]
       then
           row=$row$colval":"
       else
           row=$row$colval
       fi
       let i=$i+1 
       echo "--------"
    done
    echo "$row" >> DBs/$dbname/$1 
     echo " press enter to continue "
     read
    selectT $1
  }
#------check data type---- -
  function checkType { 
 
        read colval     
        pkexist=`cut -d: -f$pkcol DBs/$dbname/$tname | grep ^$colval$ | sed -n 1p` 
        
        if [ $pkflag = "t" ]
        then 
 	      if [[ $pkexist ]]
 	      then
 		echo -e "\t not valid ,this is the primary key and this value is repeated "
 		checkType
 	      fi  
        fi     
       
       if [ $type = "int" ]
       then
	    if ! [[ $colval =~ ^[0-9]+$ ]]
	    then 
	      echo -e "\t not valid,this col takes integer values ,enter another value .. "
	      checkType
	    else
 	      return 1     
	    fi         
       else
            if ! [[ $colval =~ ^[0-9]+$ ]]
	    then
 	      return 1 
	    else
	      echo -e "\t not valid,this col takes string ,enter another value .. "
	      checkType	       
	    fi           
       fi      
 }
# -------------------delete row --------------
  function delRow {
      clear 
      printf "\e[43m\t\t\t\t Delete Row \e[49m\n\n\n"
      select choice in 'delete based on value in all rows' 'delete row based on column value' 'cancel' 
	  do 
	    case $choice in
	      'delete based on value in all rows')
	                      echo -n " enter value to delete its row.. "
                              read delrow 
                              if test `sed -n "/$delrow/p" DBs/$dbname/$tname`
                              then 
                                    sed -i "/$delrow/d" DBs/$dbname/$tname
                              else
                                   echo -e "\t this value not exist "
                              fi
	                      break ;;
	      'delete row based on column value')
	                      echo " Delete based on where condition "
			      echo -n "enter column name " ; read colnm 
			      echo -n "column value   " ; read value
			      colmnNum=`sed -n "/$colnm/=" DBs/$dbname/meta${tname}`
			      if test $colmnNum
			      then 
				    if test `cut -d: -f$colmnNum DBs/$dbname/$tname | grep $value |sed -n 1p`
				    then				    
				         echo  "`awk -F: '{if($'$colmnNum'!="'$value'") print $0 }' DBs/$dbname/$tname`" > DBs/$dbname/$tname
# 				         sed -i "/$value/d" DBs/$dbname/$tname
				    else
				      echo -e "\t this val not exit "
				    fi 
			      else
				  echo -e "\t this col not exit "
			      fi
	                      break ;;
	      'cancel')  selectT $tname ; break ;;
	      *) echo -e "\t $REPLY is not valid." ; break ;;
	    esac
	  done     
      echo " press enter to continue "
      read
     selectT $tname
  }
# -------------------display row --------------
  function selectRow {
       clear 
       printf "\e[43m\t\t\t\t Display Row \e[49m\n\n\n"
       select choice in 'Display all rows' 'Display based on value in all rows' 'Display row based on column value' 'cancel' 
	  do 
	    case $choice in
	      'Display all rows')
	                      cat DBs/$dbname/$tname 
	                      break ;;
	      'Display based on value in all rows')
	                      echo -n " enter value to display its row.. "
                              read disrow 
                              if test `sed -n "/$disrow/p" DBs/$dbname/$tname | sed -n 1p`
                              then 
                                    sed -n "/$disrow/p" DBs/$dbname/$tname
                              else
                                   echo -e "\t this value not exist "
                              fi
	                      break ;;
	      'Display row based on column value')
	                      echo " Display based on where condition  "
			      echo -n "enter column name " ; read discolnm 
			      echo -n "column value   " ; read disvalue
			      discolmnNum=`sed -n "/$discolnm/=" DBs/$dbname/meta${tname}`
			      if test $discolmnNum
			      then 
				    if test `cut -d: -f$discolmnNum DBs/$dbname/$tname | grep $disvalue | sed -n 1p` 
				    then
				      # sed -n "/$disvalue/p" DBs/$dbname/$tname
				      awk -F: '{if($'$discolmnNum'=="'$disvalue'") print $0}' DBs/$dbname/$tname

				    else
				      echo -e "\t this value not exit "
				    fi 
			      else
				  echo -e "\t this col not exit " 
			      fi
	                      break ;;
	      'cancel')  selectT $tname ; break ;;
	      *) echo -e "\t $REPLY is not valid."; break ;;
	    esac
	  done     
      echo " press enter to continue "
      read
     selectT $tname 
  }
# -------------------update row --------------
  function updateRow {
         clear 
         printf "\e[43m\t\t\t\t Update Row \e[49m\n\n\n"
         echo " upadte based on column value where condition anothor column equal anthor value "
         echo -n "enter column name of the condition  " ; read conditionColName
         echo -n "column condition value   " ; read conditionColVal
	 echo -n "enter column name you want ot change its value  " ; read updateCol
         echo -n "enter new value  " ; read updateColVal

	 conditionColNum=`sed -n "/$conditionColName/=" DBs/$dbname/meta${tname}`
	 updateColNum=`sed -n "/$updateCol/=" DBs/$dbname/meta${tname}`
	 
	 if [[ $conditionColNum ]] && [[ $updateColNum ]]
	 then 
		    if test `cut -d: -f$conditionColNum DBs/$dbname/$tname | grep $conditionColVal | sed -n 1p`
		    then
			   echo  "`awk -F: '{if($'$conditionColNum'=="'$conditionColVal'") $'$updateColNum'="'$updateColVal'"; print $0 }' DBs/$dbname/$tname | tr ' ' ':'`" > DBs/$dbname/$tname
		    else
			    echo -e "\t this condtion val not exit "
		    fi 
	    
	 else
	   echo -e "\t one of or both these columns doesnt exist "
	 fi 
	 echo " press enter to continue "
	 read
	 selectT $tname
  }


check_validation