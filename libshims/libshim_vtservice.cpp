#include <gui/SurfaceComposerClient.h>
#include <media/AudioTrack.h>
#include <media/stagefright/MediaMuxer.h>
#include <ui/GraphicBufferMapper.h>
#include <ui/Rect.h>

using namespace android;

extern "C" {
status_t _ZN7android19GraphicBufferMapper4lockEPK13native_handlejRKNS_4RectEPPvPiS9_(
        void* thisptr, buffer_handle_t handle, uint32_t usage, const Rect& bounds, void** vaddr, int32_t* bytesPerPixel, int32_t* bytesPerStride) {
    if (bytesPerPixel) *bytesPerPixel = -1;
    if (bytesPerStride) *bytesPerStride = -1;
    return static_cast<GraphicBufferMapper*>(thisptr)->lock(handle, usage, bounds, vaddr);
}

status_t _ZN7android19GraphicBufferMapper6unlockEPK13native_handle(
        void* thisptr, buffer_handle_t handle) {
    return static_cast<GraphicBufferMapper*>(thisptr)->unlock(handle);
}
void _ZN7android10AudioTrackC1E19audio_stream_type_tj14audio_format_t20audio_channel_mask_tj20audio_output_flags_tRKNS_2wpINS0_19IAudioTrackCallbackEEEi15audio_session_tNS0_13transfer_typeEPK20audio_offload_info_tRKNS_7content22AttributionSourceStateEPK18audio_attributes_tbfi(
        void* thisptr,
        audio_stream_type_t streamType,
        uint32_t sampleRate,
        audio_format_t format,
        audio_channel_mask_t channelMask,
        size_t frameCount,
        audio_output_flags_t flags,
        const wp<AudioTrack::IAudioTrackCallback>& callback,
        int32_t notificationFrames,
        audio_session_t sessionId,
        android::AudioTrack::transfer_type transferType,
        const audio_offload_info_t *offloadInfo,
        const AttributionSourceState& attributionSource,
        const audio_attributes_t* pAttributes,
        bool doNotReconnect,
        float maxRequiredSpeed,
        audio_port_handle_t selectedDeviceId);

void _ZN7android10AudioTrackC1E19audio_stream_type_tj14audio_format_tjj20audio_output_flags_tPFviPvS4_ES4_i15audio_session_tNS0_13transfer_typeEPK20audio_offload_info_tjiPK18audio_attributes_tbfi(
        void* thisptr,
        audio_stream_type_t streamType,
        uint32_t sampleRate,
        audio_format_t format,
        audio_channel_mask_t channelMask,
        size_t frameCount,
        audio_output_flags_t flags,
        android::AudioTrack::legacy_callback_t cbf,
        void* user,
        int32_t notificationFrames,
        audio_session_t sessionId,
        android::AudioTrack::transfer_type transferType,
        const audio_offload_info_t *offloadInfo,
        uid_t uid,
        pid_t pid,
        const audio_attributes_t* pAttributes,
        bool doNotReconnect,
        float maxRequiredSpeed,
        audio_port_handle_t selectedDeviceId) {
    AttributionSourceState attributionSource;
    attributionSource.uid = uid;
    attributionSource.pid = pid;
    attributionSource.packageName = "com.mediatek.ims";
    wp<AudioTrack::IAudioTrackCallback> callback;
    _ZN7android10AudioTrackC1E19audio_stream_type_tj14audio_format_t20audio_channel_mask_tj20audio_output_flags_tRKNS_2wpINS0_19IAudioTrackCallbackEEEi15audio_session_tNS0_13transfer_typeEPK20audio_offload_info_tRKNS_7content22AttributionSourceStateEPK18audio_attributes_tbfi(
                            thisptr, streamType, sampleRate, format, channelMask, frameCount, flags, callback,
                            notificationFrames, sessionId, transferType, offloadInfo,
                            attributionSource, pAttributes, doNotReconnect, maxRequiredSpeed, selectedDeviceId);
}

void _ZN7android7SurfaceC1ERKNS_2spINS_22IGraphicBufferProducerEEEbRKNS1_INS_7IBinderEEE(
    void* thisptr, const sp<IGraphicBufferProducer>& bufferProducer, bool controlledByApp, const sp<IBinder>& surfaceControlHandle);

void _ZN7android7SurfaceC1ERKNS_2spINS_22IGraphicBufferProducerEEEb(
    void* thisptr, const sp<IGraphicBufferProducer> &bufferProducer, bool controlledByApp) {
        _ZN7android7SurfaceC1ERKNS_2spINS_22IGraphicBufferProducerEEEbRKNS1_INS_7IBinderEEE(thisptr, bufferProducer, controlledByApp, nullptr);
}

void _ZN7android10MediaMuxerC1EiNS_14MediaMuxerBase12OutputFormatE(void* thisptr, int fd, android::MediaMuxer::OutputFormat format);

void _ZN7android10MediaMuxerC1EiNS0_12OutputFormatE(void* thisptr, int fd, android::MediaMuxer::OutputFormat format) {
        _ZN7android10MediaMuxerC1EiNS_14MediaMuxerBase12OutputFormatE(thisptr, fd, format);
}

}
