import std.datetime.systime : Clock;
import std.file : readText, write, exists;
import std.conv : to, text;
import std.array : split;
import std.stdio : writeln;
import std.net.curl : get, CurlException;
import std.json : parseJSON;

void main() {
    if (shouldRefreshWeather()) {
        refreshWeather();
    }
}

int getWeather() {

    string city_id;
    string api_key;
    string url = "http://api.openweathermap.org/data/2.5/weather?id=" ~ city_id ~ "&APPID="
        ~ api_key;

    try {
        return cast(int) parseJSON(get(url))["weather"][0]["id"].integer;
    }
    catch (CurlException e) {
        return 800;
    }
}

struct FileData {
    int timestamp;
    int condition;
    int temperature; // in units kelvin, but times 100; Ex) 25C = 298.15K = 29815;
}

void refreshWeather() {
    writeWeather(getWeather(), 0);
}

bool shouldRefreshWeather() {
    return (Clock.currTime().toUnixTime() - readFile().timestamp > 60 * 15);
}

int readSavedWeather() {
    return readFile.condition;
}

string filepath = "~/.jacobscommandlineweather.txt";
FileData readFile() {

    FileData fd;
    if (!exists(filepath)) {
        fd.timestamp = 0;
        fd.condition = 0;
        fd.temperature = 0;
        writeFile(fd);
    }
    else {
        string[] lines = readText(filepath).split("\n");
        fd.timestamp = to!int(lines[0]);
        fd.condition = to!int(lines[1]);
        fd.temperature = to!int(lines[2]);
    }

    return fd;
}

void writeWeather(int code, int temp) {
    FileData fd;
    fd.timestamp = cast(int) Clock.currTime().toUnixTime();
    fd.condition = code;
    fd.temperature = temp;
    writeFile(fd);
}

void writeFile(FileData fd) {
    write(filepath, text(fd.timestamp, "\n", fd.condition, "\n", fd.temperature, "\n"));
}
