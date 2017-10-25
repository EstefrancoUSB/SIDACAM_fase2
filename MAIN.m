%====ALGORITMO PARA LA DETECCION DE BLANCOS EN EL MAR========
%
%
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%Este script funcionara como Master, contiene el código principal, desde el
%cual se ejecuta la grabación de ruido de fondo, la extracción de firmas
%acústicas, y se le da inicio al estado de análisis de detección en tiempo
%real de embarcaciones.

%% Inicializacion de variables principales
Dim_fft = 4096;        %double, Mínima longitud de ventana para óptima resolución en FFT.[]
Frec_Corte1 = 300;     %double, Frecuencia mínima de interés. [Hz]
N_Frec = 35;           %double, Número de frecuencias para determinar la firma acústica. []
Step=50;               %double, Paso del filtro pasabanda. [Hz]
condicion = 1;         %double, Flag.
realtime = 10;         %double, Duración de la grabación de la señal en tiempo real.
Frec_Muestreo = 48000; %double, Sampling Rate de 48000.
% Mientras "condicion sea "1" el programa funcionara, al tomar el valor de
% "2" se finaliza.
while condicion == 1
    
    modo = menu('Escoja la modalidad de funcionamiento del programa.',...
        'Grabación ruido de fondo.', 'Extracción firma acustica.', 'Detección de blancos.'...
        ,'SALIR.');  % Selector de estado del programa.
    
    switch modo
        %% Grabacion de ruido de fondo
        case 1
            load Base_ruidos
            
            time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            % Time Debugger
            while ischar(time) || time <=0
                disp('El tiempo de duración debe ser UN NÚMERO mayor que cero.')
                time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            end
            
            Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            % Frec_Muestreo Debugger
            while ischar(Frec_Muestreo) || Frec_Muestreo <=0
                disp('La frecuencia de muestreo debe ser UN NÚMERO mayor que cero')
                Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            end
            
            date=datestr(now);  %Guarda la fecha y la hora actual del PC
            %Crea un nombre concatenando la información necesaria de la
            %fecha y hora actual del PC
            Name_data = ['Ruido_', date(1:6), '_' date(13:14)];
            
            %Inicia la función "Grabacion" para almacenar el ruido de fondo
            [Ruido_fondo, date] = Grabacion(time,Frec_Muestreo);
            
            date = str2double(date(13:14))+ 1;
            date = num2str(date);
            %Crea el nombre que recibirá el ruido de fondo actual
            Name_data = [Name_data, '-', date]; %#ok<AGROW>
            
            %Encuentra una posición vacía en la base de datos de ruidos de
            %fondo y lo guarda
            pos = find((strcmp(Base_ruidos{1,1}, '0')),1);
            Base_ruidos{1}{pos} = Name_data;
            Base_ruidos{2}{pos}= Ruido_fondo';
            
            save('Base_ruidos','Base_ruidos')
            
            %% Extracción de Firmas Acústicas
        case 2
           
            flag = 1;
            %Ingresando el código de la embarcación
            code = input('Ingrese código de la embarcación: ', 's');
            while flag == 1
                
                %El usuario elige la manera cómo se leera la señal de la embarcación
                %con el nombre del archivo o leyéndolo desde otra ubicación
                disp ('¿Cómo leera la señal de la embarcación?');
                read = input('1-Archivo/ 2-Directorio/ 3-Grabación/: ');
                
                if read==1
                    file= input('Ingrese el nombre del archivo: ','s');
                    %Se llama la función que extrae la firma acústica de la
                    %embarcación ingresando el nombre del archivo.
                    [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
                        Frec_Corte1, N_Frec,Step,file);
                elseif read==2
                    %Cambiando el directorio donde se encuentra el archivo con la
                    %información de la embarcación.
                    path= input('Ingrese el directorio donde se encuentra el archivo: ','s');
                    file= input('Ingrese el nombre del archivo: ','s');
                    %Se llama la función que extrae la firma acústica de la
                    %embarcación especificando el directorio y el nombre del archivo.
                    [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
                        Frec_Corte1, N_Frec,Step,file,path);
                elseif read == 3
                    %Se extrae la firma acústica de una embarcación desde
                    %una captura del hidrófono.
                    time = input('Digite cuanto tiempo desea grabar [Segundos]: ');
                    [Recorrido, ~] = Grabacion(time,Frec_Muestreo);
                    [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
                        Frec_Corte1, N_Frec,Step,[],[],Recorrido);
                end
                
                %Confirmación para más grabaciones de la misma lancha.
                Mas_firmas = input('¿Desea grabar más recorridos de esta lancha? SI/NO: ', 's');
                if strcmp(Mas_firmas, 'NO')== 1
                    flag = 2;
                    disp('__________')
                end
            end
            %Extrae la firma acústica y frecuencias principales de la embarcación
            %que ha sido recién analizada
            Firma_acustica (posicion,N_Frec)
          
            
            %% Deteccion de Blancos
        case  3
            
            [Embarcacion] = Deteccion(realtime,Frec_Muestreo,Dim_fft, Frec_Corte1, N_Frec, Step);
            fprintf('La embarcación detectada puede ser: %s \n', Embarcacion)
            
        case  4
            condicion = 2;
    end
end


