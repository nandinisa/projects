#!/usr/local/bin/bash

# uses bash version 4.0 or higher
recover_folder_path='~/recover'

# creates a result folder in current execution directory
# all results will be stored here
result_dir='result'

get_file_type(){
    f_type=$(file -I ${fname}  | grep -i ".*:" | awk '{
                if (NF > 2)
                    print $(NF-1)$NF
                else
                    print $NF
            }')
    echo "$f_type"
}


# retrieve the different encodings in the files
create_file_types(){
    echo "Creating file unique encodings ..."
    f_type=()
    mkdir -p $result_dir

    for fname in "$recover_folder_path"/*;
    do
        f_type+=($( get_file_type fname ))
    done;
    unique_types=$(printf "%s\n" "${f_type[@]}" | sed 's/,$//'| sort -u)
#    printf "%s\n" "${unique_types[@]}"
    rm -f "encoding.txt"
    printf "%s\n" "${unique_types[@]}" >> "$result_dir"/encoding.txt 2>>"$result_dir"/error.txt
    echo "Done encodings ..."
}


make_associated_dirs(){
    for key in "${!file_associations[@]}";
    do
        echo "Creating result directory for ... $key"
        rm -rf "$result_dir/$key"
        mkdir -p "$result_dir/$key"
    done
}



# assign files to encoded folders
assign_folder_types(){
    echo "Assigning files to folders ..."

    declare -A file_associations
    file_associations["text"]="text/plain; charset=us-ascii text/plain;charset=unknown-8bit text/plain;charset=us-ascii text/plain;charset=utf-8"
    file_associations["pdf"]="application/pdf;charset=binary"
    file_associations["doc"]="application/msword;charset=binary"
    file_associations["docx"]="application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    file_associations["xls"]="application/vnd.ms-excel"
    file_associations["xlsx"]="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    file_associations["html"]="text/html;charset=us-ascii"


    make_associated_dirs file_associations

    for fname in "$recover_folder_path"/*;
    do
        f_type=$( get_file_type fname )
        echo "Processing $f_type.."
        name=$(basename $fname)

        if [[ $f_type == ${file_associations[html]} ]]
        then
            mv "$fname" "$result_dir/html/${name%.*}.html"

        elif [[ $f_type == ${file_associations[xlsx]} ]]
        then
            mv "$fname" "$result_dir/xlsx/${name%.*}.xlsx"
        elif [[ $f_type == ${file_associations[xls]} ]]
        then
            mv "$f_type" "$result_dir/xls/${name%.*}.xls"

        elif [[ $f_type == ${file_associations[docx]} ]]
        then
            mv "$fname" "$result_dir/docx/${name%.*}.docx"

        elif [[ $f_type == ${file_associations[doc]} ]]
        then
            mv "$fname" "$result_dir/doc/${name%.*}.doc"

        elif [[ $f_type == ${file_associations[pdf]} ]]
        then
            mv "$fname" "$result_dir/pdf/${name%.*}.pdf"

        elif [[ ${file_associations[text]} =~ "$f_type" ]]
        then
            echo "Found"
            mv "$fname" "$result_dir/text/${name%.*}.txt"
        fi
    done

    echo "Done assigning files to folders ..."
}

# execution begins here
# note deletes all directory previously created
create_file_types # use this to assign files to respective folders, currently does not read from this
assign_folder_types