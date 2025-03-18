var App = new Vue ({
  el: '#root',
  data: {
    ammunitionInWeapon: 20,
    ammunitionInStore: 100,
    textLocal: "Alonquin-Dukes Expressway",
    level : 3,
    frequence : '',
    hud : true,
    open : false,
    openWeapon : false,
    speed : 0,
    gasolina : 100,
    turbo : 100,
    belt : false,
    key : false,
    mic : 1, /* 0 sussurrando, 1 falando, 2 gritando, 3 gritando muito*/
    motor : 0,
    falando: "iconVoice",

    weather : 'extraSunny',

    hour : '18',
    minutes : '48',

    objects : {
      health : 0,
      armor : 0,
      hunger : 0,
      thirst : 0,
    },

    personalInfos : {
      health : 50,
      armor : 70,
      hunger : 60,
      thirst : 70,
    },

    gunInfos : {
      gunName : 'm4a4',
      maxAmmo : 888,
      ammo : 88
    },

    hotbar : {
      active : false,
      data : ['camera'],
    }

  },

  methods: {

    formatSpeed() {
      
      return this.speed < 10 ? '0' : ''
    },

    gasolinaFormatWidth() {
      return (this.gasolina * 187) / 100
    },

    atualizeSpeed(vaal){
      this.speed = vaal 
    },
/* 
    setGasol() {
      const boxGasol = document.querySelector('.box-gasol')
      boxGasol.style.width = `${this.gasolinaFormatWidth()}px`
    }, */


  },

  computed : {

    getVelocity() {
      return this.speed
    },

    getHealth() {
      return this.personalInfos.health
    },

    getHunger() {
      return this.personalInfos.hunger
    },

    getThirst() {
      return this.personalInfos.thirst
    },

    getArmor() {
      return this.personalInfos.armor
    },

  },

  watch : {

    getHealth(value){
        this.objects['health'].set(
            value,
            true
        );
    },

    getHunger(value){
        this.objects['hunger'].set(
            value,
            true
        );
    },
    getThirst(value){
        this.objects['thirst'].set(
            value,
            true
        );
    },
    getArmor(value){
        this.objects['armor'].set(
            value,
            true
        );
    },

},

  mounted() {

    window.addEventListener("message",function(event){
      let item =  event.data 
      if (item.type == 'inVehicle') {
        App.speed = item.data.speed
        App.level = item.data.level
        App.gasolina = item.data.gasolina
        App.belt = item.data.belt
        App.key = item.data.lockstatus
        App.motor = item.data.motor
        App.turbo = item.data.nitro
        /* App.setGasol() */
      }else if (item.type == "hotbar") {
        if (item.data) {
          App.hotbar.active = true
          App.hotbar.data = item.data
        } else {
          App.hotbar.active = false
        }
      }else if (item.type == "Falando") {
        App.falando = item.escrita
      }else if (item.type == 'open'){
        App.open = item.open
      }else if (item.type == 'info'){
      App.hud = item.data.hud
      App.personalInfos.health = item.data.health == 1 ? 0 : item.data.health
      App.personalInfos.armor = item.data.armor
      App.personalInfos.hunger = item.data.hunger
      App.textLocal = item.data.street
      App.personalInfos.thirst = item.data.thirst
    }else if (item.type == 'radio'){
      App.frequence = item.frequence
      }else if (item.type == 'voip'){
      App.mic = item.mic
      }else if (item.type == "weapon"){
      App.openWeapon = item.data.openWeapon
      App.gunInfos.gunName = item.data.gunname
      App.gunInfos.maxAmmo = item.data.maxAmmo
      App.gunInfos.ammo = item.data.ammo
      }else if (item.type == "weather"){
        App.weather = item.data.Weather
        App.hour = item.data.Hours
        App.minutes = item.data.Minutes

        if (App.hour < 10){
          App.hour = "0" + App.hour
        }

        if (App.minutes < 10){
          App.minutes = "0" + App.minutes
        }

        App.weather = App.weather.toUpperCase()
        if (App.weather == "CLEAR"){
          App.weather = "clouds"
        }else if (App.weather == "EXTRASUNNY"){
          App.weather = "extraSunny"
        }else if (App.weather == "SMOG"){
          App.weather = "smog"
        }else if (App.weather == "OVERCAST"){
          App.weather = "thunder"
        }else if (App.weather == "CLOUDS"){
          App.weather = "clouds"
        }else if (App.weather == "CLEARING"){
          App.weather = "clouds"
        }else if (App.weather == "RAIN"){
          App.weather = "rain"
        }else if (App.weather == "SNOW"){
          App.weather = "snow"
        }else if (App.weather == "XMAS"){
          App.weather = "snow"
        }else if (App.weather == "FOGGY"){
          App.weather = "foggy"
        }
      
        
      }
    });

    let percent = 100

    this.objects['health'] = new ldBar(".health", {
        "value": percent
    });

    this.objects['armor'] = new ldBar(".armor", {
        "value": percent
    });

    this.objects['thirst'] = new ldBar(".thirst", {
        "value": percent
    });

    this.objects['hunger'] = new ldBar(".hunger", {
        "value": percent
    });

/*     setTimeout(() => {
      App.personalInfos.health = 20
      App.personalInfos.armor = 20
      App.personalInfos.hunger = 20
      App.personalInfos.thirst = 20
    }, 1000);
 */
  },
  

})

