# DatasetNavigator
![alt text](https://github.com/Pin80/DatasetNavigator2/blob/master/screenshot.png?raw=true)
это небольшая утилита для создании масок изображений датасета для сегментации  
Написана на c++, Python. Использует QML, zeroMQ   
Приложение кроссплатформенное(по идеи), но проверено только под Linux. 

[![DEMO VIDEO](https://rutube.ru/video/cd10fc06784e4c47be770fda2be78e9c/)](https://rutube.ru/video/cd10fc06784e4c47be770fda2be78e9c/)

Рекомендуемое разрешение экрана 1920х1080,   
но может корректно работать на более низком разрешении, вплоть до 800х600  
Зависимости c++:  
        Qt 5.12 (минимально Qt 5.12 максимально 5.15)  
        zeromq (no binding, c bindings, c++ header) https://zeromq.org/
        
Для успешной компиляции нужно будет поменять пути к библиотекам в *.pro файлах

Зависимости python:  
    0)python3  
    1)pip install opencv-python  
    2)https://www.qt.io/qt-5-12 -> (через VPN (для россии))  
    3)pip install zmq  
    4)pip install opencv-python  
    5)pip install numpy  
    6)pip install matplotlib (на будущее)  
    7)pip install pillow  
    8)pip install scipy  
    
