from abc import abstractmethod
from typing import Optional

from dataset import CustomDataset


class MLWrapper:
    name: str

    def __init__(self, name: str):
        self.name = name

    @staticmethod
    @abstractmethod
    def train_and_evaluate(custom_dataset: CustomDataset, test_dataset: Optional[CustomDataset] = None):
        """
        :param custom_dataset:
        :param test_dataset: if this parameter is set, `custom_dataset` will be used for training only.
        :return:
        """
        pass

    def get_name(self) -> str:
        return self.name
