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

char[] getWeather() {

    string city_id;
    string api_key;
    string url = "http://api.openweathermap.org/data/2.5/weather?id=" ~ city_id ~ "&APPID="
        ~ api_key;

    try {
        import std.stdio;
        auto data = get(url);
        writeln(data);
        return data;
    }
    catch (CurlException e) {
        return [];
    }
}

struct FileData {
    int timestamp;
    int condition;
    int temperature; // in units kelvin, but times 100; Ex) 25C = 298.15K = 29815;
}

int getTempFromWeather(char[] weather) {
    if (weather == "") {
        return 0;
    }
    return cast(int)
        (parseJSON(weather)["main"]["temp"].floating * 100);
}
int getCodeFromWeather(char[] weather) {
    if (weather == "") {
        return 0;
    }
    return cast(int)
        parseJSON(weather)["weather"][0]["id"].integer;
}
void refreshWeather() {
    auto weather = getWeather();
    writeWeather(getCodeFromWeather(weather), getTempFromWeather(weather));
}

bool shouldRefreshWeather() {
    return (Clock.currTime().toUnixTime() - readFile().timestamp > 0);
}

int readSavedWeather() {
    return readFile.condition;
}

string filepath = "/home/jacob/.jacobscommandlineweather.txt";
FileData readFile() {

    FileData fd;
    if (!exists(filepath)) {
        fd.timestamp = 0;
        fd.condition = 0;
        fd.temperature = 0;
        writeFile(fd);
    }
    string[] lines = readText(filepath).split("\n");
    fd.timestamp = to!int(lines[0]);
    fd.condition = to!int(lines[1]);
    fd.temperature = to!int(lines[2]);

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
