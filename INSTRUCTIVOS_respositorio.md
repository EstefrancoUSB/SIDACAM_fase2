# SIDACAM_fase2
Repositorio para proyecto investigativo en la USB
_______________________________________________________

En este repositorio montaremos los nuevos programa de SIDACAM parte 2. No podemos crecer desordenadamente, por eso cree esta 
serie de instrucciones que nos ayuden al crecimiento organizado del respositorio y que esto no genere confusión. 


1. Se debe empezar con el archivo principal. El master deberia estar conformado solamente por este archivo inicialmente.

2. A medida que se van creando nuevas funciones, se abre una rama con el nombre de esta funcion y dentro de esta rama se crea la funcion. Esto
para ir trabajando ordenadamente. Anteriormente haciamos ramas en las que se podian cambiar varias funciones en un pull request. Esto genera
dificultad a la hora de observar todos los cambios. Si se pueden observar cambios solo por archivo se hace mas facil. 

3. Solo al final cuando se sabe que la rama funciona perfectamente se hara la juntura (merging) entre el master y la rama madre.

4. NO SE DEBEN CREAR MAS ARCHIVOS README, .txt ó .md, La idea es que en este mismo archivo (Bajo estas isntrucciones, sin borrarlas),
Generemos los instructivos del programa, el cual es sencillo y ya hicieron una vez en el pasado programa. Lo que se busca es que aqui 
se pueda explicar el funcionamiento del programa principal y las subfunciones. 

5. Recuerden, cada vez que creen una nueva branch y quieran hacer un pull request ser muy especifico en los comentarios. Este archivo 
tambien se copiara en la nueva rama creada, puden usarlo para explicar el porque de la creacion de la nueva rama y que se espera de esta. 

# MAIN

Este archivo Main será el encargado de ejercutar todas las demás funciones del algoritmo. La primera parte de este código maneja una sección de nombre "Creación base de datos", acá se determinan todas las celdas que almacenarán la información de las embarcaciones. Esta sección debe - por ahora - descomentarse la primera vez que se va a correr el algoritmo, luego se debe comentar porque sino creará de nuevo desde cero toda la base de datos cuando se vuelva a correr el código. La base de datos se almacena con el nombre de "info_barcos".

A continuación sigue la inicialización de variables, en esta parte se definen las variables que posiblemente pueda modificar el usuario, como lo son la dimensión de la fft (Dim_fft), la frecuencia de corte inferior de la señal (Frec_Corte1) y el número de frecuencias a extraer para la firma acústica (N_Frec). En esta seccción también se carga la base de datos "info_barcos" con las últimas modificaciones. 


Prosigue el ciclo While con tres diferentes casos.
- Caso 1: Grabación del ruido de fondo. Esta sección pregunta el tiempo de grabación y la frecuencia de muestreo para grabar el ruido de fondo. Usa la función "Grabación" para la captura del micrófono y la obtención de la señal capturada. La salida de esta función es la señal digitalizada junto con la fecha y hora en que se grabó. FALTA: que grabe con un nombre dado por el usuario diferentes capturas del ruido de fondo.

- Caso 2:  En esta parte el algoritmo pregunta al usuario por un archivo ya almacenado en la carpeta de trabajo de Matlab el cuál debe contener las grabaciones de las diferentes embarcaciones. El nombre del archivo queda almacenado como un ID con el cuál se puede buscar posteriormente información sobre X o Y tipo de embarcación. Si el nombre existe el algoritmo indica la posición en la que dicha lancha ya está, si no existe entonces la ubicará en una casilla vacía. 

Continúa al usar la función "Firma_acustica". Función que se explicará en otra rama. 
Finaliza el Caso 2 con la grabación de todas los datos añadidos en la base de datos.

- Caso 3: _Aún falta por codificar_

- Caso 4: modifica la condición del While para salir de dicho ciclo.


# COMENTARIOS SOBRE EL COIDGO

**Firma_acustica.m**

l33 La variable promedio no tiene que ser inicializada, es un escalar. En matlab solo se inicializan (por velocidad) vectores y matrices en ceros, o variables globales y persistentes (por funcionamiento). 

l35-36 (No se si esto es un ensayo o una fase A de la funcion pero...) No se porque la señal a analizar se extrae de 'code.waw', donde code es el codigo de la embarcacion dado en el MAIN.m, recordemos que el codigo es solo un nombre dado a la embarcación, una variable tipo string, con el cual podemos localizar la informacion que se tiene sobre esta embarcacion en el info_barcos.mat, NO ES un archivo de audio. Supongo que deberian estar usando un comando como S_blanco = audiorecorder(Frec_muestreo, nbits,nChannels). Como digo, no se si es porque estan ensayando.

l61-63 no funcionarán deben ir por fuera del for. Estas son operaciones matriciales y pueden hacerse directa sin un for, es decir:
    
    Promedio = Max_Bandas_dB/N_Frec   % primero deben hallar el promedio para poder hacer esta operacion. 
    Comparacion_Prom(:) = Max_Bandas_dB/Promedio;          
    Firma(:) =1./(Comparacion_Prom.^100;    
    Comparacion_Log(:) = log10(Comparacion_Prom); 
    
l39-58, este **for** es algo que se repetirá en la funcion deteccion.m (que no ha sido creada), se darán cuenta que tendran que repetirlo nuevamente, por eso mi propuesta fue encerrarlo en una funcion auxiliar que sea llamada cada vez que se necesite. Esto lo podemos hablar en por telefono y con computador al lado.



