%====ALGORITMO PARA LA DETECCION DE BLANCOS EN EL MAR========
%
% 
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%Este script funcionara como Master, contiene el codigo principal, desde el
%cual se ejecuta la grabacion de ruido de fondo, la extraccion de firmas
%acusticas, y se le da inicio al estado de analisis de deteccion en tiempo
%real de embarcaciones.

%% Inicializacion de variables principales
Dim_fft = 4096;        %double, Minima longitud de ventana para optima resolucion en FFT.[]
Frec_Corte1 = 300;     %double, Frecuencia minima de interes. [Hz]
N_Frec = 35;           %double, Numero de frecuencias para determinar la firma acustica. []
Step=50;               %double, Paso del filtro pasabanda [Hz]
condicion = 1;         %double, Flag
realtime = 10;         %double, Duracion de la grabacion de la señal en tiempo real
Frec_Muestreo = 44100; %double, Sampling Rate de 44100
% Mientras "condicion sea "1" el programa funcionara, al tomar el valor de
% "2" se finaliza
while condicion == 1
    
    modo = menu('Escoja la modalidad de funcionamiento del programa.',...
        'Grabacion ruido de fondo.', 'Extraccion firma acustica.', 'Deteccion de blancos.'...
        ,'SALIR.');  % Selector de estado del programa.
    
    switch modo
        %% Grabacion de ruido de fondo
        case 1
            load Base_ruidos
            
            time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            % Time Debugger
            while ischar(time) || time <=0
                disp('El tiempo de duracion debe ser UN NUMERO mayor que cero')
                time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            end
            
            Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            % Frec_Muestreo Debugger
            while ischar(Frec_Muestreo) || Frec_Muestreo <=0
                disp('La frecuencia de muestreo debe ser UN NUMERO mayor que cero')
                Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            end
            
            date=datestr(now);  %Guarda la fecha y la hora actual del PC
            %Crea un nombre concatenando la informacion necesaria de la
            %fecha y hora actual del PC
            Name_data = ['Ruido_', date(1:6), '_' date(13:14)];
            
            %Inicia la funion "Grabacion" para almacenar el ruido de fondo
            [Ruido_fondo, date] = Grabacion(time,Frec_Muestreo);
            
            date = str2double(date(13:14))+ 1;
            date = num2str(date);
            %Crea el nombre que recibira el ruido de fondo actual
            Name_data = [Name_data, '-', date];
            
            %Encuentra una posicion vacia en la base de datos de ruidos de
            %fondo y lo guarda
            pos = find((strcmp(Base_ruidos{1,1}, '0')),1);
            Base_ruidos{1}{pos} = Name_data;
            Base_ruidos{2}{pos}= Ruido_fondo';
            
            save('Base_ruidos','Base_ruidos')
                        
            %% Extraccion de Firmas Acusticas
        case 2
%El usuario elige la manera como se leera la señal de la embarcacion, 
%por medio del codigo, con el nombre del archivo o leyendolo desde otra ubicaión            
read=input('¿Como leera la señal de la embarcacion?- / 1-Codigo/ 2-Archivo/ 3-Directorio/: ');
     
%Ingresando el codigo de la embarcación
     if read==1
         
         code = input('Ingrese nombre o codigo de la embarcacion: ', 's');
         %Se llama la funcion que extrae la firma acustica de la
         %embarcacion solo con el codigo
         [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
             Frec_Corte1, N_Frec,Step);
%Ingresando el nombre del archivo
     elseif read==2
         file= input('Ingrese el nombre del archivo: ','s');
         %Se llama la funcion que extrae la firma acustica de la
         %embarcacion ingresando el nombre del archivo
         [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
             Frec_Corte1, N_Frec,Step,file);
%Cambiando el directorio donde se encuentra el archivo con la
%informacion de la embarcacion
     elseif read==3
         path= input('Ingrese el directorio donde se encuentra el archivo: ','s');
         file= input('Ingrese el nombre del archivo: ','s');
         %Se llama la funcion que extrae la firma acustica de la
         %embarcacion sespecificando el directorio y el nombre del archivo
         [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
             Frec_Corte1, N_Frec,Step,file,path);
         
     end
     %Extrae la firma acustica de la embarcacion que ha sido recien analizada 
     
     Firma_acustica (posicion,N_Frec)
     
            
            %% Deteccion de Blancos
        case 3
            
            [Embarcacion] = Deteccion(realtime,Frec_Muestreo,Dim_fft, Frec_Corte1, N_Frec, Step);
            fprintf('La embarcacion detectada puede ser: %s \n', Embarcacion)
            
            
        case 4
            condicion = 2;
    end
end