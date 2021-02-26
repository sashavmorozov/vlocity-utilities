global class DefaultHookImpl implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName,
        Map <String, Object> inputs,
        Map <String, Object> output,
        Map <String, Object> options) {

        system.debug('_____________________________ CpqAppHandlerHook ' + methodName);

        return true;
    }
}