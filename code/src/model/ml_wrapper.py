from abc import abstractmethod

from dataset import CustomDataset


class MLWrapper:
    name: str

    def __init__(self, name: str):
        self.name = name

    @staticmethod
    @abstractmethod
    def train_and_evaluate(custom_dataset: CustomDataset):
        pass

    def get_name(self) -> str:
        return self.name