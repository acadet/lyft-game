var CONFIG, Car, CarMoveEvent, DoubleHelper, DropEvent, DropZone, DropZoneVanishedEvent, EventBus, GameOverEvent, Grid, HomePresenter, IncreaseDifficultyEvent, PickupEvent, PickupZone, PickupZoneVanishedEvent, Point, PointHelper, PopupManager, RideEngine, ScoreManager, StartEvent, USER_SOURCE, UserEngine, Zone, homeController,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

CONFIG = {
  blockSize: 200,
  streetSize: 10,
  carSpeed: 10 * 1000,
  pickupFrequency: 5 * 1000,
  pickupDuration: 10 * 1000,
  pickupAnimationDelay: 3 * 1000,
  dropDuration: 10 * 1000,
  dropAnimationDelay: 10 * 1000,
  missedPickupFare: 10,
  missedDropFare: 30,
  successfulDropFare: 50,
  bonusTip: 1,
  tipSpeedRatio: 0.5
};

CarMoveEvent = (function() {
  function CarMoveEvent() {}

  CarMoveEvent.NAME = 'CarMoveEvent';

  return CarMoveEvent;

})();

PickupEvent = (function() {
  PickupEvent.NAME = 'PickupEvent';

  function PickupEvent(zone) {
    this.zone = zone;
  }

  PickupEvent.prototype.getZone = function() {
    return this.zone;
  };

  return PickupEvent;

})();

DropEvent = (function() {
  DropEvent.NAME = 'DropEvent';

  function DropEvent(zone, speedRatio) {
    this.zone = zone;
    this.speedRatio = speedRatio;
  }

  DropEvent.prototype.getZone = function() {
    return this.zone;
  };

  DropEvent.prototype.getSpeedRatio = function() {
    return this.speedRatio;
  };

  return DropEvent;

})();

PickupZoneVanishedEvent = (function() {
  PickupZoneVanishedEvent.NAME = 'PickupZoneVanishedEvent';

  function PickupZoneVanishedEvent(id) {
    this.id = id;
  }

  PickupZoneVanishedEvent.prototype.getId = function() {
    return this.id;
  };

  return PickupZoneVanishedEvent;

})();

DropZoneVanishedEvent = (function() {
  DropZoneVanishedEvent.NAME = 'DropZoneVanishedEvent';

  function DropZoneVanishedEvent(id) {
    this.id = id;
  }

  DropZoneVanishedEvent.prototype.getId = function() {
    return this.id;
  };

  return DropZoneVanishedEvent;

})();

GameOverEvent = (function() {
  function GameOverEvent() {}

  GameOverEvent.NAME = 'GameOverEvent';

  return GameOverEvent;

})();

StartEvent = (function() {
  function StartEvent() {}

  StartEvent.NAME = 'StartEvent';

  return StartEvent;

})();

IncreaseDifficultyEvent = (function() {
  function IncreaseDifficultyEvent() {}

  IncreaseDifficultyEvent.NAME = 'IncreaseDifficultyEvent';

  return IncreaseDifficultyEvent;

})();

EventBus = (function() {
  EventBus.BUSES = {};

  function EventBus(name) {
    this.name = name;
    this.listeners = {};
  }

  EventBus.prototype.register = function(name, callback) {
    if (this.listeners.hasOwnProperty(name)) {
      return this.listeners[name].push(callback);
    } else {
      return this.listeners[name] = [callback];
    }
  };

  EventBus.prototype.post = function(name, data) {
    var l, len, m, ref, results;
    if (!this.listeners.hasOwnProperty(name)) {
      return;
    }
    ref = this.listeners[name];
    results = [];
    for (m = 0, len = ref.length; m < len; m++) {
      l = ref[m];
      results.push(l(data));
    }
    return results;
  };

  EventBus.getDefault = function() {
    return EventBus.get('default');
  };

  EventBus.get = function(name) {
    var b;
    if (!EventBus.BUSES.hasOwnProperty(name)) {
      b = new EventBus(name);
      EventBus.BUSES[name] = b;
    }
    return EventBus.BUSES[name];
  };

  return EventBus;

})();

DoubleHelper = (function() {
  function DoubleHelper() {}

  DoubleHelper.TOLERANCE = 3;

  DoubleHelper.compare = function(a, b, tolerance) {
    if (tolerance == null) {
      tolerance = DoubleHelper.TOLERANCE;
    }
    return Math.abs(a - b) <= tolerance;
  };

  return DoubleHelper;

})();

PointHelper = (function() {
  function PointHelper() {}

  PointHelper.compare = function(p1, p2, tolerance) {
    return DoubleHelper.compare(p1.getX(), p2.getX(), tolerance) && DoubleHelper.compare(p1.getY(), p2.getY(), tolerance);
  };

  return PointHelper;

})();

Point = (function() {
  function Point(x, y) {
    this.x = x;
    this.y = y;
  }

  Point.prototype.getX = function() {
    return this.x;
  };

  Point.prototype.setX = function(value) {
    return this.x = value;
  };

  Point.prototype.getY = function() {
    return this.y;
  };

  Point.prototype.setY = function(value) {
    return this.y = value;
  };

  Point.prototype.toString = function() {
    return this.x + " - " + this.y;
  };

  return Point;

})();

Grid = (function() {
  Grid.TARGET_TOLERANCE = 20;

  Grid.FILL_COLOR = '#fff';

  Grid.STROKE_COLOR = '#EAE2D8';

  function Grid(source, blockSize, streetSize) {
    this.source = $(source);
    this.snap = Snap(source);
    this.blockSize = blockSize;
    this.streetSize = streetSize;
    this.gridWidth = this.source.width() - (this.source.outerWidth() % this.blockSize);
    this.gridHeight = this.source.height() - (this.source.outerHeight() % this.blockSize);
    this.verticalStreetNumber = Math.floor(this.gridWidth / this.blockSize) + 1;
    this.horizontalStreetNumber = Math.floor(this.gridHeight / this.blockSize) + 1;
  }

  Grid.prototype.getSource = function() {
    return this.source;
  };

  Grid.prototype.getSnap = function() {
    return this.snap;
  };

  Grid.prototype.getStreetSize = function() {
    return this.streetSize;
  };

  Grid.prototype.getBlockSize = function() {
    return this.blockSize;
  };

  Grid.prototype.render = function() {
    var horizontalStreet, i, j, m, n, ref, ref1, results, square, verticalStreet, z;
    for (i = m = 0, ref = Math.max(this.horizontalStreetNumber, this.verticalStreetNumber); 0 <= ref ? m < ref : m > ref; i = 0 <= ref ? ++m : --m) {
      z = i * this.blockSize;
      if (!(i >= this.horizontalStreetNumber)) {
        horizontalStreet = this.snap.rect(0, z, this.gridWidth, this.streetSize);
      }
      if (!(i >= this.verticalStreetNumber)) {
        verticalStreet = this.snap.rect(z, 0, this.streetSize, this.gridHeight);
      }
      horizontalStreet.attr({
        fill: Grid.FILL_COLOR,
        stroke: Grid.STROKE_COLOR
      });
      verticalStreet.attr({
        fill: Grid.FILL_COLOR,
        stroke: Grid.STROKE_COLOR
      });
    }
    results = [];
    for (i = n = 0, ref1 = this.verticalStreetNumber; 0 <= ref1 ? n < ref1 : n > ref1; i = 0 <= ref1 ? ++n : --n) {
      results.push((function() {
        var p, ref2, results1;
        results1 = [];
        for (j = p = 0, ref2 = this.horizontalStreetNumber; 0 <= ref2 ? p < ref2 : p > ref2; j = 0 <= ref2 ? ++p : --p) {
          square = this.snap.circle(i * this.blockSize + this.streetSize / 2, j * this.blockSize + this.streetSize / 2, this.streetSize);
          results1.push(square.attr({
            fill: Grid.FILL_COLOR
          }));
        }
        return results1;
      }).call(this));
    }
    return results;
  };

  Grid.prototype.randomCrossStreets = function() {
    var i, j;
    i = Math.round(Math.random() * (this.verticalStreetNumber - 1));
    j = Math.round(Math.random() * (this.horizontalStreetNumber - 1));
    return new Point(i * this.blockSize + this.streetSize / 2, j * this.blockSize + this.streetSize / 2);
  };

  Grid.prototype.randomPosition = function() {
    var isHorizontal, x, y;
    isHorizontal = Math.round(Math.random()) === 0;
    x = null;
    y = null;
    if (isHorizontal) {
      x = Math.round(Math.random() * this.gridWidth);
      y = Math.round(Math.random() * (this.horizontalStreetNumber - 1)) * this.blockSize + this.streetSize / 2;
    } else {
      x = Math.round(Math.random() * (this.verticalStreetNumber - 1)) * this.blockSize + this.streetSize / 2;
      y = Math.round(Math.random() * this.gridHeight);
    }
    return new Point(x, y);
  };

  Grid.prototype.isWithinAStreet = function(position) {
    var i, j, m, n, ref, ref1, x, y;
    for (i = m = 0, ref = this.verticalStreetNumber; 0 <= ref ? m < ref : m > ref; i = 0 <= ref ? ++m : --m) {
      x = i * this.blockSize + this.streetSize / 2;
      if (DoubleHelper.compare(position.getX(), x, this.streetSize / 2 + Grid.TARGET_TOLERANCE)) {
        return true;
      }
    }
    for (j = n = 0, ref1 = this.horizontalStreetNumber; 0 <= ref1 ? n < ref1 : n > ref1; j = 0 <= ref1 ? ++n : --n) {
      y = j * this.blockSize + this.streetSize / 2;
      if (DoubleHelper.compare(position.getY(), y, this.streetSize / 2 + Grid.TARGET_TOLERANCE)) {
        return true;
      }
    }
    return false;
  };

  Grid.prototype.isACrossStreet = function(position) {
    var a, b, i, j, m, n, ref, ref1, x, y;
    a = false;
    for (i = m = 0, ref = this.verticalStreetNumber; 0 <= ref ? m < ref : m > ref; i = 0 <= ref ? ++m : --m) {
      x = i * this.blockSize + this.streetSize / 2;
      if (DoubleHelper.compare(position.getX(), x, this.streetSize / 2)) {
        a = true;
        break;
      }
    }
    if (a == null) {
      return false;
    }
    b = false;
    for (j = n = 0, ref1 = this.horizontalStreetNumber; 0 <= ref1 ? n < ref1 : n > ref1; j = 0 <= ref1 ? ++n : --n) {
      y = j * this.blockSize + this.streetSize / 2;
      if (DoubleHelper.compare(position.getY(), y, this.streetSize / 2)) {
        b = true;
        break;
      }
    }
    return a && b;
  };

  Grid.prototype.realign = function(position) {
    var a, b, i, j, m, n, ref, ref1, x, y;
    x = position.getX();
    for (i = m = 0, ref = this.verticalStreetNumber; 0 <= ref ? m < ref : m > ref; i = 0 <= ref ? ++m : --m) {
      a = i * this.blockSize + this.streetSize / 2;
      if (DoubleHelper.compare(a, position.getX(), this.streetSize / 2 + Grid.TARGET_TOLERANCE)) {
        x = a;
        break;
      }
    }
    y = position.getY();
    for (j = n = 0, ref1 = this.horizontalStreetNumber; 0 <= ref1 ? n < ref1 : n > ref1; j = 0 <= ref1 ? ++n : --n) {
      b = j * this.blockSize + this.streetSize / 2;
      if (DoubleHelper.compare(b, position.getY(), this.streetSize / 2 + Grid.TARGET_TOLERANCE)) {
        y = b;
        break;
      }
    }
    return new Point(x, y);
  };

  Grid.prototype.getPrevHorizontalCross = function(position) {
    var j, y;
    y = position.getY();
    if (y % this.blockSize <= this.streetSize) {
      y -= y % this.blockSize;
    }
    j = Math.ceil(y / this.blockSize) - 1;
    if (j < 0) {
      return position;
    }
    return new Point(position.getX(), j * this.blockSize + this.streetSize / 2);
  };

  Grid.prototype.getNextHorizontalCross = function(position) {
    var j, y;
    y = position.getY();
    if (y % this.blockSize === 0) {
      y++;
    }
    j = Math.ceil(y / this.blockSize);
    if (j >= this.horizontalStreetNumber) {
      return position;
    }
    return new Point(position.getX(), j * this.blockSize + this.streetSize / 2);
  };

  Grid.prototype.getPrevVerticalCross = function(position) {
    var i, x;
    x = position.getX();
    if (x % this.blockSize <= this.streetSize) {
      x -= x % this.blockSize;
    }
    i = Math.ceil(x / this.blockSize) - 1;
    if (i < 0) {
      return position;
    }
    return new Point(i * this.blockSize + this.streetSize / 2, position.getY());
  };

  Grid.prototype.getNextVerticalCross = function(position) {
    var i, x;
    x = position.getX();
    if (x % this.blockSize === 0) {
      x++;
    }
    i = Math.ceil(x / this.blockSize);
    if (i >= this.verticalStreetNumber) {
      return position;
    }
    return new Point(i * this.blockSize + this.streetSize / 2, position.getY());
  };

  return Grid;

})();

Car = (function() {
  var MAX_CALL_STACK, Orientation, StreetDirection;

  MAX_CALL_STACK = 30;

  StreetDirection = (function() {
    function StreetDirection() {}

    StreetDirection.CROSS = 0;

    StreetDirection.HORIZONTAL = 1;

    StreetDirection.VERTICAL = 2;

    return StreetDirection;

  })();

  Orientation = (function() {
    function Orientation() {}

    Orientation.UP = 0;

    Orientation.RIGHT = 1;

    Orientation.DOWN = 2;

    Orientation.LEFT = 3;

    return Orientation;

  })();

  function Car(source, grid, speed) {
    this.source = $(source);
    this.carWidth = parseInt(this.source.attr('width'));
    this.carHeight = parseInt(this.source.attr('height'));
    this.grid = grid;
    this.speed = speed;
    this.currentPosition = this.grid.randomCrossStreets();
    this._refreshPosition();
    this.currentStreetDirection = StreetDirection.CROSS;
    this.currentAnimation = null;
  }

  Car.prototype._stopAnimation = function() {
    if (this.currentAnimation != null) {
      clearTimeout(this.currentAnimation);
      return this.currentAnimation = null;
    }
  };

  Car.prototype._refreshPosition = function() {
    this.source.attr('x', this.currentPosition.getX() - this.carWidth / 2);
    return this.source.attr('y', this.currentPosition.getY() - this.carHeight / 2);
  };

  Car.prototype._animateTo = function(point, direction, orientation, callback) {
    if (PointHelper.compare(this.currentPosition, point)) {
      return callback();
    } else {
      return this.currentAnimation = setTimeout((function(_this) {
        return function() {
          var k;
          k = -1;
          if (orientation === Orientation.DOWN || orientation === Orientation.RIGHT) {
            k = 1;
          }
          if (direction === StreetDirection.HORIZONTAL) {
            _this.currentPosition.setX(_this.currentPosition.getX() + k);
          } else {
            _this.currentPosition.setY(_this.currentPosition.getY() + k);
          }
          _this._refreshPosition();
          EventBus.get('Car').post(CarMoveEvent.NAME, new CarMoveEvent());
          return _this._animateTo(point, direction, orientation, callback);
        };
      })(this), 1 / this.speed);
    }
  };

  Car.prototype._moveTo = function(target) {
    var callback, horizontalMove, neighborhoodLimit, shouldMoveHorizontal, verticalMove;
    if (this.callStack >= MAX_CALL_STACK) {
      this._stopAnimation();
      return;
    }
    this.callStack++;
    if (PointHelper.compare(this.currentPosition, target)) {
      return;
    }
    if (this.grid.isACrossStreet(this.currentPosition)) {
      this.currentStreetDirection = StreetDirection.CROSS;
    }
    callback = (function(_this) {
      return function() {
        return _this._moveTo(target);
      };
    })(this);
    neighborhoodLimit = this.grid.getBlockSize() - this.grid.getStreetSize() / 2;
    verticalMove = (function(_this) {
      return function() {
        var nextPosition, orientation, statement;
        nextPosition = null;
        orientation = null;
        statement = Math.abs(target.getY() - _this.currentPosition.getY()) < neighborhoodLimit;
        statement &= DoubleHelper.compare(target.getX(), _this.currentPosition.getX());
        if (statement) {
          nextPosition = target;
          if (target.getY() <= _this.currentPosition.getY()) {
            orientation = Orientation.UP;
          } else {
            orientation = Orientation.DOWN;
          }
        } else {
          if (target.getY() <= _this.currentPosition.getY()) {
            orientation = Orientation.UP;
            nextPosition = _this.grid.getPrevHorizontalCross(_this.currentPosition);
          } else {
            orientation = Orientation.DOWN;
            nextPosition = _this.grid.getNextHorizontalCross(_this.currentPosition);
          }
        }
        _this.currentStreetDirection = StreetDirection.VERTICAL;
        return _this._animateTo(nextPosition, StreetDirection.VERTICAL, orientation, callback);
      };
    })(this);
    horizontalMove = (function(_this) {
      return function() {
        var nextPosition, orientation, statement;
        nextPosition = null;
        orientation = null;
        statement = Math.abs(target.getX() - _this.currentPosition.getX()) < neighborhoodLimit;
        statement &= DoubleHelper.compare(target.getY(), _this.currentPosition.getY());
        if (statement) {
          nextPosition = target;
          if (target.getX() <= _this.currentPosition.getX()) {
            orientation = Orientation.LEFT;
          } else {
            orientation = Orientation.RIGHT;
          }
        } else {
          if (target.getX() <= _this.currentPosition.getX()) {
            orientation = Orientation.LEFT;
            nextPosition = _this.grid.getPrevVerticalCross(_this.currentPosition);
          } else {
            orientation = Orientation.RIGHT;
            nextPosition = _this.grid.getNextVerticalCross(_this.currentPosition);
          }
        }
        _this.currentStreetDirection = StreetDirection.HORIZONTAL;
        return _this._animateTo(nextPosition, StreetDirection.HORIZONTAL, orientation, callback);
      };
    })(this);
    if (this.currentStreetDirection === StreetDirection.VERTICAL) {
      return verticalMove();
    } else if (this.currentStreetDirection === StreetDirection.HORIZONTAL) {
      return horizontalMove();
    } else {
      if (DoubleHelper.compare(target.getX(), this.currentPosition.getX())) {
        return verticalMove();
      } else if (DoubleHelper.compare(target.getY(), this.currentPosition.getY())) {
        return horizontalMove();
      } else if (Math.abs(target.getX() - this.currentPosition.getX()) < neighborhoodLimit) {
        return verticalMove();
      } else if (Math.abs(target.getY() - this.currentPosition.getY()) < neighborhoodLimit) {
        return horizontalMove();
      } else {
        shouldMoveHorizontal = Math.round(Math.random()) === 0;
        if (shouldMoveHorizontal) {
          return horizontalMove();
        } else {
          return verticalMove();
        }
      }
    }
  };

  Car.prototype.getSpeed = function() {
    return this.speed;
  };

  Car.prototype.setSpeed = function(v) {
    return this.speed = v;
  };

  Car.prototype.getCurrentPosition = function() {
    return this.currentPosition;
  };

  Car.prototype.requestMove = function(target) {
    if (!this.grid.isWithinAStreet(target)) {
      return;
    }
    this.callStack = 0;
    this._stopAnimation();
    return this._moveTo(this.grid.realign(target));
  };

  return Car;

})();

USER_SOURCE = [
  {
    name: 'Al',
    profile_picture_src: 'pacino.jpeg',
    location: 'NYC',
    music: 'Johnny Cash, Neil Young',
    likes: 'Chainsaws, having sympathy for the devil'
  }, {
    name: 'Robert',
    profile_picture_src: 'de_niro.jpg',
    location: 'NYC',
    music: 'Eric Clapton, Rolling Stones',
    likes: 'Pasta, taxis, Italy <3'
  }, {
    name: 'Ewan',
    profile_picture_src: 'mcgregor.jpg',
    location: 'London',
    music: 'Beatles, Yardbirds',
    likes: 'Fishing, cars, Arrr Scotland'
  }, {
    name: 'Natalie',
    profile_picture_src: 'portman.jpg',
    location: 'NYC',
    music: 'Otis Reeding, Phoenix',
    likes: 'Dancing, Anakin, Nicholson'
  }, {
    name: 'Morgan',
    profile_picture_src: 'freeman.jpg',
    location: 'Los Angeles',
    music: 'Chet Baker, Miles Davis',
    likes: 'Mozart, Badgadgets, anyone on Earth'
  }, {
    name: 'Logan',
    profile_picture_src: 'green.jpg',
    location: 'Menlo Park',
    music: 'Chilly Gonzales, Chet Faker',
    likes: 'Vroom, beach, biking'
  }, {
    name: 'John',
    profile_picture_src: 'zimmer.jpg',
    location: 'Greenwhich',
    music: 'Bob Dylan, CCR',
    likes: 'Rock n roll, Lyft <3'
  }, {
    name: 'Kristin',
    profile_picture_src: 'thomas.jpg',
    location: 'London',
    music: 'Armstrong, Led Zeppelin',
    likes: 'Charming guys, being a spy'
  }, {
    name: 'Bruce',
    profile_picture_src: 'willis.jpg',
    location: 'LA',
    music: 'Otis Redding, Phil Collins',
    likes: 'Destroying buildings, kicking asses'
  }, {
    name: 'Emma',
    profile_picture_src: 'watson.jpg',
    location: 'London',
    music: 'Elton John, Franz Ferdinand',
    likes: 'Wingardium leviosa, photography'
  }, {
    name: 'Ralph',
    profile_picture_src: 'fiennes.jpg',
    location: 'London',
    music: 'The Stranglers, The Police',
    likes: 'Planes, Budapest'
  }, {
    name: 'Tom',
    profile_picture_src: 'hanks.jpg',
    location: 'LA',
    music: 'Woodkid, The White Stripes',
    likes: 'Wilson, running, Ryan'
  }
];

UserEngine = (function() {
  function UserEngine(dest, elementSelector) {
    var id, len, m, o, u;
    this.dest = $(dest);
    this.elementSelector = elementSelector;
    this.template = $('#template-user-profile').html();
    Mustache.parse(this.template);
    this.active = {};
    this.activeSize = 0;
    this.users = [];
    id = 0;
    for (m = 0, len = USER_SOURCE.length; m < len; m++) {
      u = USER_SOURCE[m];
      o = u;
      o.id = id++;
      this.users.push(o);
    }
  }

  UserEngine.prototype.showRandom = function(color) {
    var id, u;
    if (this.activeSize === this.users.length) {
      return;
    }
    id = -1;
    while ((id < 0) || this.active.hasOwnProperty(id)) {
      id = Math.round(Math.random() * (this.users.length - 1));
    }
    u = this.users[id];
    u.color = color;
    this.dest.append(Mustache.render(this.template, u));
    this.dest.find(this.elementSelector).each((function(_this) {
      return function(i, e) {
        var parsedId;
        parsedId = parseInt($(e).data('id'));
        if (parsedId === id) {
          $(e).addClass(color);
          return false;
        }
      };
    })(this));
    this.active[id] = u;
    this.activeSize++;
    return id;
  };

  UserEngine.prototype.hide = function(id) {
    return this.dest.find(this.elementSelector).each((function(_this) {
      return function(i, e) {
        var parsedId;
        parsedId = parseInt($(e).data('id'));
        if (parsedId === id) {
          delete _this.active[id];
          _this.activeSize--;
          $(e).parent().remove();
          return false;
        }
      };
    })(this));
  };

  return UserEngine;

})();

Zone = (function() {
  Zone.SIZE = 30;

  Zone.colors = [
    {
      label: 'red',
      inUse: false
    }, {
      label: 'blue',
      inUse: false
    }, {
      label: 'purple',
      inUse: false
    }, {
      label: 'green',
      inUse: false
    }
  ];

  Zone.colorInUse = 0;

  function Zone(id, grid, color) {
    this.id = id;
    this.grid = grid;
    this.color = color;
  }

  Zone.prototype._animate = function() {
    this.animationTimer = null;
    return this.icon.animate({
      x: this.position.getX(),
      y: this.position.getY(),
      width: 0,
      height: 0
    }, this.duration, null, (function(_this) {
      return function() {
        _this.hide();
        return _this.postVanished();
      };
    })(this));
  };

  Zone.prototype.getId = function() {
    return this.id;
  };

  Zone.prototype.getColor = function() {
    return this.color;
  };

  Zone.prototype.setDuration = function(v) {
    return this.duration = v;
  };

  Zone.prototype.setAnimationDelay = function(v) {
    return this.animationDelay = v;
  };

  Zone.prototype.getImgExtension = function() {};

  Zone.prototype.postVanished = function() {};

  Zone.prototype.isNearMe = function(point) {
    return PointHelper.compare(point, this.position, Zone.SIZE);
  };

  Zone.prototype.show = function() {
    this.position = this.grid.randomPosition();
    this.icon = this.grid.getSnap().image("imgs/" + this.color + "-" + (this.getImgExtension()) + ".png", this.position.getX() - Zone.SIZE / 2, this.position.getY() - Zone.SIZE / 2, Zone.SIZE, Zone.SIZE);
    return this.animationTimer = setTimeout((function(_this) {
      return function() {
        return _this._animate();
      };
    })(this), this.animationDelay);
  };

  Zone.prototype.hide = function() {
    if (this.animationTimer != null) {
      clearTimeout(this.animationTimer);
    }
    this.icon.stop();
    return this.icon.remove();
  };

  Zone.provideColor = function() {
    var color, randomIndex;
    randomIndex = (function(_this) {
      return function() {
        return Math.round(Math.random() * (Zone.colors.length - 1));
      };
    })(this);
    if (Zone.colorInUse >= Zone.colors.length) {
      Zone.colorInUse++;
      return Zone.colors[randomIndex()].label;
    }
    while (true) {
      color = Zone.colors[randomIndex()];
      if (!color.inUse) {
        color.inUse = true;
        Zone.colorInUse++;
        return color.label;
      }
    }
  };

  return Zone;

})();

PickupZone = (function(superClass) {
  extend(PickupZone, superClass);

  function PickupZone(id, grid) {
    PickupZone.__super__.constructor.call(this, id, grid, Zone.provideColor());
  }

  PickupZone.prototype.getImgExtension = function() {
    return 'balloon';
  };

  PickupZone.prototype.postVanished = function() {
    return EventBus.get('Zone').post(PickupZoneVanishedEvent.NAME, new PickupZoneVanishedEvent(this.getId()));
  };

  return PickupZone;

})(Zone);

DropZone = (function(superClass) {
  extend(DropZone, superClass);

  function DropZone(id, grid, color) {
    DropZone.__super__.constructor.call(this, id, grid, color);
  }

  DropZone.prototype.getImgExtension = function() {
    return 'marker';
  };

  DropZone.prototype.postVanished = function() {
    return EventBus.get('Zone').post(DropZoneVanishedEvent.NAME, new DropZoneVanishedEvent(this.getId()));
  };

  DropZone.prototype.hide = function() {
    var e, len, m, ref, results;
    DropZone.__super__.hide.apply(this, arguments);
    Zone.colorInUse--;
    ref = Zone.colors;
    results = [];
    for (m = 0, len = ref.length; m < len; m++) {
      e = ref[m];
      if (e.label === this.getColor()) {
        e.inUse = false;
        break;
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return DropZone;

})(Zone);

RideEngine = (function() {
  RideEngine.MAX_RIDES = 4;

  function RideEngine(grid, car) {
    this.grid = grid;
    this.car = car;
    this.generator = null;
    EventBus.get('Car').register(CarMoveEvent.NAME, (function(_this) {
      return function(e) {
        return _this.onCarMove(e);
      };
    })(this));
    EventBus.get('Zone').register(PickupZoneVanishedEvent.NAME, (function(_this) {
      return function(e) {
        return _this.onPickupZoneVanished(e);
      };
    })(this));
    EventBus.get('Zone').register(DropZoneVanishedEvent.NAME, (function(_this) {
      return function(e) {
        return _this.onDropZoneVanished(e);
      };
    })(this));
  }

  RideEngine.prototype._startGenerating = function() {
    return this.generator = setInterval((function(_this) {
      return function() {
        var z;
        z = new PickupZone(_this.idCounter, _this.grid);
        z.setDuration(_this.pickupDuration);
        z.setAnimationDelay(_this.pickupAnimationDelay);
        z.show();
        _this.pickupZones[_this.idCounter] = z;
        return _this.idCounter++;
      };
    })(this), this.pickupFrequency);
  };

  RideEngine.prototype.getPickupFrequency = function() {
    return this.pickupFrequency;
  };

  RideEngine.prototype.setPickupFrequency = function(v) {
    this.pickupFrequency = v;
    if (this.generator == null) {
      return;
    }
    clearInterval(this.generator);
    return this._startGenerating();
  };

  RideEngine.prototype.getPickupDuration = function() {
    return this.pickupDuration;
  };

  RideEngine.prototype.setPickupDuration = function(v) {
    return this.pickupDuration = v;
  };

  RideEngine.prototype.getPickupAnimationDelay = function() {
    return this.pickupAnimationDelay;
  };

  RideEngine.prototype.setPickupAnimationDelay = function(v) {
    return this.pickupAnimationDelay = v;
  };

  RideEngine.prototype.getDropDuration = function() {
    return this.dropDuration;
  };

  RideEngine.prototype.setDropDuration = function(v) {
    return this.dropDuration = v;
  };

  RideEngine.prototype.getDropAnimationDelay = function() {
    return this.dropAnimationDelay;
  };

  RideEngine.prototype.setDropAnimationDelay = function(v) {
    return this.dropAnimationDelay = v;
  };

  RideEngine.prototype.start = function() {
    this.pickupZones = {};
    this.dropZones = {};
    this.idCounter = 0;
    return this._startGenerating();
  };

  RideEngine.prototype.stop = function() {
    var id, ref, ref1, results, wrapper, zone;
    clearInterval(this.generator);
    ref = this.pickupZones;
    for (id in ref) {
      zone = ref[id];
      zone.hide();
    }
    ref1 = this.dropZones;
    results = [];
    for (id in ref1) {
      wrapper = ref1[id];
      results.push(wrapper.zone.hide());
    }
    return results;
  };

  RideEngine.prototype.onCarMove = function(e) {
    var currentRides, d, dropZoneToRemove, id, len, len1, m, n, pickupZoneToRemove, ref, ref1, results, speedRatio, wrapper, zone;
    pickupZoneToRemove = [];
    dropZoneToRemove = [];
    currentRides = Object.keys(this.dropZones).length;
    ref = this.dropZones;
    for (id in ref) {
      wrapper = ref[id];
      if (wrapper.zone.isNearMe(this.car.getCurrentPosition())) {
        wrapper.zone.hide();
        speedRatio = (Date.now() - wrapper.startTime) / this.dropDuration;
        EventBus.get('RideEngine').post(DropEvent.NAME, new DropEvent(wrapper.zone, speedRatio));
        dropZoneToRemove.push(id);
        currentRides--;
      }
    }
    ref1 = this.pickupZones;
    for (id in ref1) {
      zone = ref1[id];
      if (currentRides === RideEngine.MAX_RIDES) {
        break;
      }
      if (zone.isNearMe(this.car.getCurrentPosition())) {
        zone.hide();
        EventBus.get('RideEngine').post(PickupEvent.NAME, new PickupEvent(zone));
        d = new DropZone(id, this.grid, zone.getColor());
        d.setDuration(this.dropDuration);
        d.setAnimationDelay(this.dropAnimationDelay);
        d.show();
        this.dropZones[id] = {
          startTime: Date.now(),
          zone: d
        };
        pickupZoneToRemove.push(id);
        currentRides++;
      }
    }
    for (m = 0, len = pickupZoneToRemove.length; m < len; m++) {
      e = pickupZoneToRemove[m];
      delete this.pickupZones[e];
    }
    results = [];
    for (n = 0, len1 = dropZoneToRemove.length; n < len1; n++) {
      e = dropZoneToRemove[n];
      results.push(delete this.dropZones[e]);
    }
    return results;
  };

  RideEngine.prototype.onPickupZoneVanished = function(e) {
    return delete this.pickupZones[e.getId()];
  };

  RideEngine.prototype.onDropZoneVanished = function(e) {
    return delete this.dropZones[e.getId()];
  };

  return RideEngine;

})();

ScoreManager = (function() {
  function ScoreManager(selector) {
    this.displayer = $(selector);
    this.currentScore = 50;
    this.maxScore = 0;
    this.nextStep = 300;
    this._refreshScore(true);
    EventBus.get('Zone').register(PickupZoneVanishedEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onMissedPickup(z);
      };
    })(this));
    EventBus.get('Zone').register(DropZoneVanishedEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onMissedDrop(z);
      };
    })(this));
    EventBus.get('RideEngine').register(DropEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onDrop(z);
      };
    })(this));
  }

  ScoreManager.prototype._refreshScore = function(isIncreasing) {
    this.maxScore = Math.max(this.maxScore, this.currentScore);
    if (this.currentScore < 0) {
      this.currentScore = 0;
      EventBus.get('ScoreManager').post(GameOverEvent.NAME, new GameOverEvent());
    }
    this.displayer.text("$" + this.currentScore);
    if (isIncreasing) {
      this.displayer.addClass('increase');
    } else {
      this.displayer.addClass('decrease');
    }
    this.displayer.fadeOut(400, (function(_this) {
      return function() {
        return _this.displayer.fadeIn(400);
      };
    })(this));
    return setTimeout((function(_this) {
      return function() {
        return _this.displayer.removeClass('increase decrease');
      };
    })(this), 1200);
  };

  ScoreManager.prototype.getMaxScore = function() {
    return this.maxScore;
  };

  ScoreManager.prototype.getMissedPickupFare = function() {
    return this.missedPickupFare;
  };

  ScoreManager.prototype.setMissedPickupFare = function(v) {
    return this.missedPickupFare = v;
  };

  ScoreManager.prototype.getMissedDropFare = function() {
    return this.missedDropFare;
  };

  ScoreManager.prototype.setMissedDropFare = function(v) {
    return this.missedDropFare = v;
  };

  ScoreManager.prototype.getSuccessfulDropFare = function() {
    return this.successfulDropFare;
  };

  ScoreManager.prototype.setSuccessfulDropFare = function(v) {
    return this.successfulDropFare = v;
  };

  ScoreManager.prototype.getBonusTip = function() {
    return this.bonusTip;
  };

  ScoreManager.prototype.setBonusTip = function(v) {
    return this.bonusTip = v;
  };

  ScoreManager.prototype.getTipSpeedRatio = function() {
    return this.tipSpeedRatio;
  };

  ScoreManager.prototype.setTipSpeedRatio = function(v) {
    return this.tipSpeedRatio = v;
  };

  ScoreManager.prototype.onMissedPickup = function(e) {
    this.currentScore -= this.missedPickupFare;
    return this._refreshScore(false);
  };

  ScoreManager.prototype.onMissedDrop = function(e) {
    this.currentScore -= this.missedDropFare;
    return this._refreshScore(false);
  };

  ScoreManager.prototype.onDrop = function(e) {
    if (e.getSpeedRatio() <= this.tipSpeedRatio) {
      this.currentScore += this.bonusTip;
    }
    this.currentScore += this.successfulDropFare;
    this._refreshScore(true);
    if (this.currentScore >= this.nextStep) {
      this.nextStep *= 2;
      return EventBus.get('ScoreManager').post(IncreaseDifficultyEvent.NAME, new IncreaseDifficultyEvent());
    }
  };

  return ScoreManager;

})();

PopupManager = (function() {
  function PopupManager() {
    this.wrapper = $('.js-popup-wrapper');
    this.startPopup = $('.js-starting-popup');
    this.endPopup = $('.js-ending-popup');
    this.startPopup.find('.js-confirmation').first().on('click', (function(_this) {
      return function() {
        return _this.onConfirmation();
      };
    })(this));
  }

  PopupManager.prototype._showWrapper = function() {
    this.wrapper.removeClass('hidden');
    this.wrapper.css('opacity', 0);
    return this.wrapper.animate({
      opacity: 1
    }, 1000);
  };

  PopupManager.prototype._showPopup = function(popup) {
    $(popup).css({
      top: (this.wrapper.outerHeight() - $(popup).outerHeight()) / 2,
      left: (this.wrapper.outerWidth() - $(popup).outerWidth()) / 2
    });
    popup.children().each((function(_this) {
      return function(i, e) {
        return $(e).css('opacity', 0);
      };
    })(this));
    return popup.show('puff', null, 1000, (function(_this) {
      return function() {
        return popup.children().each(function(i, e) {
          return $(e).animate({
            opacity: 1
          }, 250);
        });
      };
    })(this));
  };

  PopupManager.prototype.showStart = function() {
    this._showWrapper();
    return this._showPopup(this.startPopup);
  };

  PopupManager.prototype.showEnding = function(duration, maxBalance) {
    var content, inMinutes;
    inMinutes = Math.round(duration / 1000 / 60);
    content = " " + inMinutes + " minute";
    if (inMinutes > 1) {
      content += "s";
    }
    if (inMinutes < 1) {
      content = " less than a minute";
    }
    this._showWrapper();
    this.endPopup.find('.js-game-countdown').first().append(content);
    this.endPopup.find('.js-game-max-balance').first().append(maxBalance);
    return this._showPopup(this.endPopup);
  };

  PopupManager.prototype.onConfirmation = function() {
    this.startPopup.remove();
    this.wrapper.addClass('hidden');
    return EventBus.getDefault().post(StartEvent.NAME, new StartEvent());
  };

  return PopupManager;

})();

HomePresenter = (function() {
  function HomePresenter() {}

  HomePresenter.prototype._initCar = function() {
    var c;
    c = this.grid.getSnap().image('imgs/car.png', 0, 0, 20, 20);
    c.addClass('js-car');
    return this.car = new Car('.js-car', this.grid, CONFIG.carSpeed);
  };

  HomePresenter.prototype._initRideEngine = function() {
    this.rideEngine = new RideEngine(this.grid, this.car);
    this.rideEngine.setPickupFrequency(CONFIG.pickupFrequency);
    this.rideEngine.setPickupDuration(CONFIG.pickupDuration);
    this.rideEngine.setPickupAnimationDelay(CONFIG.pickupAnimationDelay);
    this.rideEngine.setDropDuration(CONFIG.dropDuration);
    this.rideEngine.setDropAnimationDelay(CONFIG.dropAnimationDelay);
    EventBus.get('RideEngine').register(PickupEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onPickup(z);
      };
    })(this));
    EventBus.get('RideEngine').register(DropEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onDrop(z);
      };
    })(this));
    EventBus.get('Zone').register(DropZoneVanishedEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onMissedDrop(z);
      };
    })(this));
    return EventBus.getDefault().register(StartEvent.NAME, (function(_this) {
      return function() {
        _this.startTime = Date.now();
        return _this.rideEngine.start();
      };
    })(this));
  };

  HomePresenter.prototype._initScoreManager = function() {
    this.isOver = false;
    this.scoreManager = new ScoreManager('.js-score');
    this.scoreManager.setMissedPickupFare(CONFIG.missedPickupFare);
    this.scoreManager.setMissedDropFare(CONFIG.missedDropFare);
    this.scoreManager.setSuccessfulDropFare(CONFIG.successfulDropFare);
    this.scoreManager.setBonusTip(CONFIG.bonusTip);
    this.scoreManager.setTipSpeedRatio(CONFIG.tipSpeedRatio);
    EventBus.get('ScoreManager').register(GameOverEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onGameOver(z);
      };
    })(this));
    return EventBus.get('ScoreManager').register(IncreaseDifficultyEvent.NAME, (function(_this) {
      return function(z) {
        return _this.onIncreasingDifficulty(z);
      };
    })(this));
  };

  HomePresenter.prototype.onStart = function() {
    this.grid = new Grid('.js-map', CONFIG.blockSize, CONFIG.streetSize);
    this.grid.render();
    this.currentRides = {};
    this._initCar();
    this._initRideEngine();
    this._initScoreManager();
    this.userEngine = new UserEngine('.js-user-list', '.js-user-card');
    $('.js-map').on('click', (function(_this) {
      return function(e) {
        var x, y;
        x = e.pageX - _this.grid.getSource().offset().left - parseInt(_this.grid.getSource().css('padding-left'));
        y = e.pageY - _this.grid.getSource().offset().top - parseInt(_this.grid.getSource().css('padding-top'));
        return _this.car.requestMove(new Point(x, y));
      };
    })(this));
    this.pickupSound = new Audio('sounds/car.mp3');
    this.dropSound = new Audio('sounds/cash.mp3');
    this.popupManager = new PopupManager();
    return this.popupManager.showStart();
  };

  HomePresenter.prototype.onPickup = function(e) {
    var o;
    o = {
      zone: e.getZone(),
      user: this.userEngine.showRandom(e.getZone().getColor())
    };
    this.currentRides[e.getZone().getId()] = o;
    return this.pickupSound.play();
  };

  HomePresenter.prototype.onMissedDrop = function(e) {
    var o;
    o = this.currentRides[e.getId()];
    this.userEngine.hide(o.user);
    return delete this.currentRides[e.getId()];
  };

  HomePresenter.prototype.onDrop = function(e) {
    var id, o;
    id = e.getZone().getId();
    o = this.currentRides[e.getZone().getId()];
    this.userEngine.hide(o.user);
    delete this.currentRides[id];
    return this.dropSound.play();
  };

  HomePresenter.prototype.onGameOver = function(e) {
    if (this.isOver) {
      return;
    }
    this.isOver = true;
    this.rideEngine.stop();
    return this.popupManager.showEnding(Date.now() - this.startTime, this.scoreManager.getMaxScore());
  };

  HomePresenter.prototype.onIncreasingDifficulty = function(e) {
    this.rideEngine.setPickupFrequency(this.rideEngine.getPickupFrequency() / 2);
    if (this.rideEngine.getPickupDuration() > 3) {
      this.rideEngine.setPickupDuration(this.rideEngine.getPickupDuration() - 1);
      if (this.rideEngine.getPickupDuration() <= this.rideEngine.getPickupAnimationDelay()) {
        this.rideEngine.setPickupAnimationDelay(0);
      }
    }
    if (this.rideEngine.getDropDuration() > 3) {
      this.rideEngine.setDropDuration(this.rideEngine.getDropDuration() - 1);
      if (this.rideEngine.getDropDuration() <= this.rideEngine.getDropAnimationDelay) {
        this.rideEngine.setDropAnimationDelay(0);
      }
    }
    this.scoreManager.setMissedPickupFare(Math.round(this.scoreManager.getMissedPickupFare() * 2));
    this.scoreManager.setMissedDropFare(Math.round(this.scoreManager.getMissedDropFare() * 2));
    this.scoreManager.setSuccessfulDropFare(Math.round(this.scoreManager.getSuccessfulDropFare() * 1.5));
    return this.scoreManager.setBonusTip(Math.round(this.scoreManager.getBonusTip() * 2));
  };

  return HomePresenter;

})();

homeController = new HomePresenter().onStart();
