package cn.msun.event {
    import cn.msun.core.mlib_internal;
    
    import flash.utils.getQualifiedClassName;
    use namespace mlib_internal;
    
    /**
     * @author Msun
     */
    public class Event {
        public static const REMOVE_FROM_TICKER:String = "removeFromTicker";
        
        private static var pool:Vector.<Event> = new <Event>[];
        
        private var _target:EventSender;
        private var _currentTarget:EventSender;
        private var _type:String;
        private var _bubbles:Boolean;
        private var _stopsPropagation:Boolean;
        private var _stopsImmediatePropagation:Boolean;
        private var _data:Object;
        
        public function Event(type:String, bubbles:Boolean = false, data:Object = null) {
            this._type = type;
            this._bubbles = bubbles;
            this._data = data;
        }
        
        public function stopPropagation():void {
            _stopsPropagation = true;
        }
        
        public function stopImmediatePropagation():void {
            _stopsPropagation = _stopsImmediatePropagation = true;
        }
        
        public function toString():String {
            var name:String = getQualifiedClassName(this).split("::").pop();
            return '[' + name + 'type="' + _type + '" bubbles="' + _bubbles + '"]';
        }
        
        public function get bubbles():Boolean {
            return _bubbles;
        }
        
        public function get target():EventSender {
            return _target;
        }
        
        public function get currentTarget():EventSender {
            return _currentTarget;
        }
        
        public function get type():String {
            return _type;
        }
        
        public function get data():Object {
            return _data;
        }
        
        internal function setTarget(value:EventSender):void {
            _target = value;
        }
        
        internal function setCurrentTarget(value:EventSender):void {
            _currentTarget = value;
        }
        
        internal function get stopsPropagation():Boolean {
            return _stopsPropagation;
        }
        
        internal function get stopsImmediatePropagation():Boolean {
            return _stopsImmediatePropagation;
        }
        
        // event pooling
        mlib_internal static function fromPool(type:String, bubbles:Boolean = false, data:Object = null):Event {
            if(pool.length)
                return Event(pool.pop()).reset(type, bubbles, data);
            else
                return new Event(type, bubbles, data);
        }
        
        mlib_internal static function toPool(event:Event):void {
            event._data = event._target = event._currentTarget = null;
            pool.push(event);
        }
        
        mlib_internal function reset(type:String, bubbles:Boolean = false, data:Object = null):Event {
            _type = type;
            _bubbles = bubbles;
            _data = data;
            _target = _currentTarget = null;
            _stopsPropagation = _stopsImmediatePropagation = false;
            return this;
        }
    }
}
