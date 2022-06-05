import librosa

def detectTempo(fileName):
    y, sr = librosa.load(fileName, sr=None)
    onset_env = librosa.onset.onset_strength(y=y, sr=sr)
    tempo = librosa.beat.tempo(onset_envelope=onset_env, sr=sr)
    return tempo[0]