%====ALGORITMO PARA LA DETECCION DE BLANCOS EN EL MAR========
%
%
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%Este script funcionara como Master, contiene el c�digo principal, desde el
%cual se ejecuta la grabaci�n de ruido de fondo, la extracci�n de firmas
%ac�sticas, y se le da inicio al estado de an�lisis de detecci�n en tiempo
%real de embarcaciones.

%% Inicializacion de variables principales
Dim_fft = 4096;        %double, M�nima longitud de ventana para �ptima resoluci�n en FFT.[]
Frec_Corte1 = 300;     %double, Frecuencia m�nima de inter�s. [Hz]
N_Frec = 35;           %double, N�mero de frecuencias para determinar la firma ac�stica. []
Step=50;               %double, Paso del filtro pasabanda. [Hz]
condicion = 1;         %double, Flag.
realtime = 10;         %double, Duraci�n de la grabaci�n de la se�al en tiempo real.
Frec_Muestreo = 48000; %double, Sampling Rate de 48000.
% Mientras "condicion sea "1" el programa funcionara, al tomar el valor de
% "2" se finaliza.
while condicion == 1
    
    modo = menu('Escoja la modalidad de funcionamiento del programa.',...
        'Grabaci�n ruido de fondo.', 'Extracci�n firma acustica.', 'Detecci�n de blancos.'...
        ,'SALIR.');  % Selector de estado del programa.
    
    switch modo
        %% Grabacion de ruido de fondo
        case 1
            load Base_ruidos
            
            time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            % Time Debugger
            while ischar(time) || time <=0
                disp('El tiempo de duraci�n debe ser UN N�MERO mayor que cero.')
                time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            end
            
            Frec_Muestreo = input('Defina la frecuencia de muestreo de la se�al [Hz]: ');
            % Frec_Muestreo Debugger
            while ischar(Frec_Muestreo) || Frec_Muestreo <=0
                disp('La frecuencia de muestreo debe ser UN N�MERO mayor que cero')
                Frec_Muestreo = input('Defina la frecuencia de muestreo de la se�al [Hz]: ');
            end
            
            date=datestr(now);  %Guarda la fecha y la hora actual del PC
            %Crea un nombre concatenando la informaci�n necesaria de la
            %fecha y hora actual del PC
            Name_data = ['Ruido_', date(1:6), '_' date(13:14)];
            
            %Inicia la funci�n "Grabacion" para almacenar el ruido de fondo
            [Ruido_fondo, date] = Grabacion(time,Frec_Muestreo);
            
            date = str2double(date(13:14))+ 1;
            date = num2str(date);
            %Crea el nombre que recibir� el ruido de fondo actual
            Name_data = [Name_data, '-', date]; %#ok<AGROW>
            
            %Encuentra una posici�n vac�a en la base de datos de ruidos de
            %fondo y lo guarda
            pos = find((strcmp(Base_ruidos{1,1}, '0')),1);
            Base_ruidos{1}{pos} = Name_data;
            Base_ruidos{2}{pos}= Ruido_fondo';
            
            save('Base_ruidos','Base_ruidos')
            
            %% Extracci�n de Firmas Ac�sticas
        case 2
           
            flag = 1;
            %Ingresando el c�digo de la embarcaci�n
            code = input('Ingrese c�digo de la embarcaci�n: ', 's');
            while flag == 1
                
                %El usuario elige la manera c�mo se leera la se�al de la embarcaci�n
                %con el nombre del archivo o ley�ndolo desde otra ubicaci�n
                disp ('�C�mo leera la se�al de la embarcaci�n?');
                read = input('1-Archivo/ 2-Directorio/ 3-Grabaci�n/: ');
                
                if read==1
                    file= input('Ingrese el nombre del archivo: ','s');
                    %Se llama la funci�n que extrae la firma ac�stica de la
                    %embarcaci�n ingresando el nombre del archivo.
                    [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
                        Frec_Corte1, N_Frec,Step,file);
                elseif read==2
                    %Cambiando el directorio donde se encuentra el archivo con la
                    %informaci�n de la embarcaci�n.
                    path= input('Ingrese el directorio donde se encuentra el archivo: ','s');
                    file= input('Ingrese el nombre del archivo: ','s');
                    %Se llama la funci�n que extrae la firma ac�stica de la
                    %embarcaci�n especificando el directorio y el nombre del archivo.
                    [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
                        Frec_Corte1, N_Frec,Step,file,path);
                elseif read == 3
                    %Se extrae la firma ac�stica de una embarcaci�n desde
                    %una captura del hidr�fono.
                    time = input('Digite cuanto tiempo desea grabar [Segundos]: ');
                    [Recorrido, ~] = Grabacion(time,Frec_Muestreo);
                    [posicion,Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
                        Frec_Corte1, N_Frec,Step,[],[],Recorrido);
                end
                
                %Confirmaci�n para m�s grabaciones de la misma lancha.
                Mas_firmas = input('�Desea grabar m�s recorridos de esta lancha? SI/NO: ', 's');
                if strcmp(Mas_firmas, 'NO')== 1
                    flag = 2;
                    disp('__________')
                end
            end
            %Extrae la firma ac�stica y frecuencias principales de la embarcaci�n
            %que ha sido reci�n analizada
            Firma_acustica (posicion,N_Frec)
          
            
            %% Deteccion de Blancos
        case  3
            
            [Embarcacion] = Deteccion(realtime,Frec_Muestreo,Dim_fft, Frec_Corte1, N_Frec, Step);
            fprintf('La embarcaci�n detectada puede ser: %s \n', Embarcacion)
            
        case  4
            condicion = 2;
    end
end


