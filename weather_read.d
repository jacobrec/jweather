import std.datetime.systime : Clock;
import std.file: readText, write, exists;
import std.conv: to, text;
import std.array: split;
import std.stdio: writeln;
import std.net.curl: get, CurlException;
import std.json: parseJSON;

void main(){
    writeln(handleRequest());
}

int handleRequest(){
    int weather = readSavedWeather();
    return compressAPICode(weather);
}

int compressAPICode(int code){
    /+
        SUNNY: 0
        CLOUDY: 1
        OVERCAST: 2
        RAINY: 3
        STORMY: 4
        SNOWY: 5
        +/
    switch(code){
        case 200:// 200 level means lighting
            ..
        case 299:
            return 4;
        case 300: // 300 level is drizzle
            ..
        case 450: // 400 level is not real
            goto case; // limit of 255 cases in a case range, so I need to split it up
        case 451:
            ..
        case 599: // 500 level is rain
            return 3;
        case 600:
            ..
        case 699: // 600 level is snow
           return 5;
        case 700:
           ..
        case 799: // 700 level is atmosphere, eg) fog, smoke, ash
           return 2;
        case 800: // 800 is clear
        case 801: // 800 is few clouds
           return 0;

        case 802: // 802 is scattered clouds
        case 803: // 803 is broken clouds
               return 1;
        case 804:
               return 2;
        default:
            return 0; // otherwise, im going to pretend it's sunny
    }
}


struct FileData{
    int timestamp;
    int condition;
    int temperature; // in units kelvin, but times 100; Ex) 25C = 298.15K = 29815;
}

int readSavedWeather(){
    return readFile.condition;
}

string filepath = "/home/jacob/.jacobscommandlineweather.txt";
FileData readFile(){

    FileData fd;
    if(!exists(filepath)){
        fd.timestamp = 0;
        fd.condition = 0;
        fd.temperature = 0;
        writeFile(fd);
    }else{
        string[] lines = readText(filepath).split("\n");
        fd.timestamp = to!int(lines[0]);
        fd.condition = to!int(lines[1]);
        fd.temperature = to!int(lines[2]);
    }

    return fd;
}

void writeFile(FileData fd){
    write(filepath, text(fd.timestamp, "\n", fd.condition, "\n", fd.temperature, "\n"));
}

