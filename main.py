import sys
from aubio import source, onset
import numpy as np
import librosa
import librosa.display
import matplotlib.pyplot as plt

# win_s = 1024                 # fft size
# hop_s = win_s // 2          # hop size

# s = source('audio/AR_Lick1_KN.wav', hop_size=hop_s)
# samplerate = s.samplerate

# o = onset("default", win_s, hop_s, samplerate)

# # list of onsets, in samples
# onsets = []

# # total number of frames read
# total_frames = 0
# hamming_win = np.hamming(hop_s).astype('float32')
# while True:
#     samples, read = s()
#     samples = samples*hamming_win
#     if o(samples):
#         print("%f" % o.get_last_s())
#         onsets.append(o.get_last()/samplerate)
#     total_frames += read
#     if read < hop_s: break
# print(len(onsets))

# y, sr = librosa.load('audio/AR_Lick1_KN.wav', sr=None)
# librosa.onset.onset_detect(y=y, sr=sr, units='time')

# o_env = librosa.onset.onset_strength(y=y, sr=sr)
# times = librosa.times_like(o_env, sr=sr)
# onset_frames = librosa.onset.onset_detect(onset_envelope=o_env, sr=sr)

# D = np.abs(librosa.stft(y))
# fig, ax = plt.subplots(nrows=2, sharex=True)
# librosa.display.specshow(librosa.amplitude_to_db(D, ref=np.max),
#                          x_axis='time', y_axis='log', ax=ax[0])
# ax[0].set(title='Power spectrogram')
# ax[0].label_outer()
# ax[1].plot(times, o_env, label='Onset strength')
# ax[1].vlines(times[onset_frames], 0, o_env.max(), color='r', alpha=0.9,
#            linestyle='--', label='Onsets')
# ax[1].legend()
# plt.show()

y, sr = librosa.load('audio/AR_Lick6_KN.wav', sr=None)
onset_env = librosa.onset.onset_strength(y=y, sr=sr)
tempo = librosa.beat.tempo(onset_envelope=onset_env, sr=sr)
print(tempo)