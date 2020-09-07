var _stopTimer = false;

$(function(){
    window.addEventListener("message", function(event){   
        if(event.data.type == "show_game_ui") {
            $('#header').show();
        } else if (event.data.type == "show_game_scoreboard") {
            $('#game_scoreboard').toggle();
        } else if (event.data.type == "update_game_ui") {
            this.console.log(event.data);
            mapUI(event.data);
        } else if (event.data.type == "update_game_ui_win") {
            mapUI(event.data);
            showWinTeam(event.data);
        } else if (event.data.type == "update_game_ui_lose") {
            mapUI(event.data);
            showWinTeam(event.data);
        } else if(event.data.type == "match_start") {
            startMatch();
        } else if(event.data.type == "new_round") {
            $('#who_won').hide();
            // reset time
            startMatch();
        } else if (event.data.type == "endgame") {
            Speak("Tráº­n Ä‘áº¥u Ä‘Ã£ káº¿t thÃºc!");
            $('#header').hide();
            this.location.reload();
        } else if(event.data.type == "update_game_ui_win_finished") {
            // mapUI(event.data);
            this.console.log(event.data);
            showWinTeam(event.data, true);
        } else if(event.data.type == "voice_anount") {
            Anount(event.data.team, event.data.kill);
        }
    });
});

function mapUI(data)
{
    var _blueTeam = data.game_ui.BlueTeam;
    var _redTeam = data.game_ui.RedTeam;
    // Blue players
    var _index = 0;
    for(var i = 0; i < _blueTeam.player_list.length; i++) {
        if (_blueTeam.player_list[i] != undefined) {
            _index++;
            $(`.blue-team[data-player-id="${_index}"] .bar_username`).text(_blueTeam.player_list[i].name);
            $(`.blue-team[data-player-id="${_index}"] .kills`).eq(1).text(_blueTeam.player_list[i].kill);
            $(`.blue-team[data-player-id="${_index}"] .deaths`).eq(1).text(_blueTeam.player_list[i].death);
            $(`.blue-team[data-player-id="${_index}"]`).show();
        }
    }
    // Score
    $('.blue_score').text(_blueTeam.score);
    // Red players
    var _index = 0;
    for(var i = 0; i < _redTeam.player_list.length; i++) {
        if (_redTeam.player_list[i] != undefined) {
            _index++;
            $(`.red-team[data-player-id="${_index}"] .bar_username`).text(_redTeam.player_list[i].name);
            $(`.red-team[data-player-id="${_index}"] .kills`).eq(1).text(_redTeam.player_list[i].kill);
            $(`.red-team[data-player-id="${_index}"] .deaths`).eq(1).text(_redTeam.player_list[i].death);
            $(`.red-team[data-player-id="${_index}"]`).show();
        }
    }
    // Score
    $('.red_score').text(_redTeam.score);
    //
}

function showWinTeam(data, finished)
{
    var _textSpeak = "";
    if(data.win_team == "RedTeam") {
        $('#winning_team').html(`<span class="red">Red Team</span>`);
        _textSpeak = "The red team has won!";
        // Speak("Äá»™i Ä‘á» Ä‘Ã£ chiáº¿n tháº¯ng!");
    } else {
        $('#winning_team').html(`<span class="blue">Blue Team</span>`);
        _textSpeak = "The blue team has won!";
        // Speak("Äá»™i xanh Ä‘Ã£ chiáº¿n tháº¯ng!");
    }
    $('#who_won').fadeIn();
    if(finished) {
        $('.div_info').html(`The match will end in <span class="red" id="remain_time">15</span> seconds more!`);
        _textSpeak += " The match will end in 15 seconds!";
    }
    Speak(_textSpeak);

    _stopTimer = true;
    var _sec = 15;
    var _interVal = setInterval(function () {
        $('#remain_time').text(_sec); 
        _sec--;

        if(_sec < 0) {
            clearInterval(_interVal);
        }
    }, 1000);
    
}

function startTimer(duration, display) {
    var timer = duration, minutes, seconds;
    var _interVal = setInterval(function () {
        minutes = parseInt(timer / 60, 10);
        seconds = parseInt(timer % 60, 10);

        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        display.text(minutes + ":" + seconds);

        if (--timer < 0) {
            timer = duration;
        }
        if(_stopTimer) {
            clearInterval(_interVal);
        }
    }, 1000);
}

function startMatch() {
    _stopTimer = false;
    $('#who_won').hide();
    var fiveMinutes = 60 * 3,
        display = $('#time_counter');
    startTimer(fiveMinutes, display);
    Speak("The match has started!");
}

function Speak(text) {
    $('#speak_ai').attr("src", "https://translate.google.com/translate_tts?ie=UTF-8&q="+encodeURI(text)+"&tl=en-us&total=1&idx=0&client=tw-ob");
    // $('#speak_ai').play();
    document.getElementById('speak_ai').play();
}

function Anount(_team, _kill) {
    $('#anount_ai').attr("src", _anount[_team][_kill]);
    document.getElementById('anount_ai').play();
}

var _anount = [];
_anount["allied"] = [];
_anount["allied"]["double"] = "sounds/DoubleKill.mp3";
_anount["allied"]["triple"] = "sounds/TripleKill.mp3";
_anount["allied"]["quadra"] = "sounds/QuadraKill.mp3";
_anount["allied"]["penta"] = "sounds/PentaKill.mp3";
_anount["enemy"] = [];
_anount["enemy"]["double"] = "sounds/EnemyDoubleKill.mp3";
_anount["enemy"]["triple"] = "sounds/EnemyTripleKill.mp3";
_anount["enemy"]["quadra"] = "sounds/EnemyQuadraKill.mp3";
_anount["enemy"]["penta"] = "sounds/EnemyPentaKill.mp3";
// console.log(_anount);
