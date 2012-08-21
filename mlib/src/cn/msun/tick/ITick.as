package cn.msun.tick {
    
    /**
     * @author Msun
     */
    public interface ITick {
        
        /**
         * @param tickTime 此次tick的毫秒数
         * @param totalTime 过去的毫秒数
         * @param frame 过去的帧数
         */
        function tick(tickTime:uint, totalTime:uint, frame:uint):void;
    }
}
