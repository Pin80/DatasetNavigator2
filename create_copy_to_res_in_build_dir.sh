#! /bin/bash

software_folder=/home/user/MySoftware/DatasetNavigator2
build_folder=/home/user/MyBuild/build_datasetnavigator2

target=$software_folder"/settings.json"
name=$build_folder"/settings.json"
target2=$software_folder"/images"
name2=$build_folder"/images"
target3=$software_folder"/annot_tool.py"
name3=$build_folder"/annot_tool.py"
target4=$software_folder"/qml"
name4=$build_folder"/qml"
target5=$software_folder"/doc"
name5=$build_folder"/doc"
target6=$software_folder"/license.txt"
name6=$build_folder"/license.txt"
# if link is not created

if [ ! -e $name ]
then
    cp -r $target $build_folder
else
	echo "copy have already created!"
fi

if [ ! -d $name2 ]
then
	cp -r $target2 $build_folder
else
	echo "copy folder have already created!"
fi

if [ ! -e $name3 ]
then
	cp -r $target3 $build_folder
else
	echo "copy have already created!"
fi

if [ ! -d $name4 ]
then
	cp -r $target4 $build_folder
else
	echo "copy folder have already created!"
fi

if [ ! -d $name5 ]
then
        cp -r $target5 $build_folder
else
        echo "copy folder have already created!"
fi

if [ ! -e $name6 ]
then
        cp -r $target6 $build_folder
else
        echo "copy have already created!"
fi
